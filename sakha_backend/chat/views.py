from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from .models import ChatSession, ChatMessage
from .serializers import ChatSessionSerializer, ChatMessageSerializer
from .utils import generate_chat_name, generate_bot_response, store_chat_log_mongo, get_cached_chat_context, cache_chat_context
from django.shortcuts import get_object_or_404

class ChatSessionListCreateAPIView(generics.ListCreateAPIView):
    serializer_class = ChatSessionSerializer

    def get_queryset(self):
        # Get tenant id from Firebase (attached by middleware)
        tenant_id = self.request.firebase_user.get("uid")
        return ChatSession.objects.filter(tenant_id=tenant_id).order_by("-created_at")

    def perform_create(self, serializer):
        tenant_id = self.request.firebase_user.get("uid")
        language = self.request.data.get("language", "en")
        # Optionally, generate a chat name via GPT-4 and cache it in Redis
        chat_name = generate_chat_name(tenant_id=tenant_id, language=language)
        serializer.save(tenant_id=tenant_id, name=chat_name, language=language)

class ChatMessageListCreateAPIView(APIView):
    """
    GET: List all messages in a chat session.
    POST: Send a user message and get a bot reply.
    """
    def get(self, request, session_id):
        tenant_id = request.firebase_user.get("uid")
        session = get_object_or_404(ChatSession, id=session_id, tenant_id=tenant_id)
        serializer = ChatMessageSerializer(session.messages.all().order_by("timestamp"), many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, session_id):
        tenant_id = request.firebase_user.get("uid")
        session = get_object_or_404(ChatSession, id=session_id, tenant_id=tenant_id)
        user_text = request.data.get("text")
        if not user_text:
            return Response({"detail": "Text field is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Save the user message
        user_message = ChatMessage.objects.create(session=session, sender="user", text=user_text)
        # Optionally, update cached context
        context = get_cached_chat_context(str(session.id)) or ""
        updated_context = f"{context}\nUser: {user_text}"
        cache_chat_context(str(session.id), updated_context)

        # Generate bot response using RAG chain (this calls LangChain and Pinecone)
        bot_response = generate_bot_response(user_query=user_text, chat_context=updated_context, language=session.language)

        # Save the bot response
        bot_message = ChatMessage.objects.create(session=session, sender="bot", text=bot_response)
        # Update cache
        updated_context = f"{updated_context}\nBot: {bot_response}"
        cache_chat_context(str(session.id), updated_context)

        # Optionally, store the conversation in MongoDB for analytics/audit.
        store_chat_log_mongo(session_id=str(session.id), message_data={
            "user": user_text,
            "bot": bot_response,
            "timestamp": user_message.timestamp.isoformat()
        })

        # Return both the user and bot messages
        serializer = ChatMessageSerializer([user_message, bot_message], many=True)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
