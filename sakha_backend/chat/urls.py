from django.urls import path
from . import views

urlpatterns = [
    # List and create chat sessions
    path("chats/", views.ChatSessionListCreateAPIView.as_view(), name="chat_sessions"),
    # List messages in a session
    path("chats/<uuid:session_id>/messages/", views.ChatMessageListCreateAPIView.as_view(), name="chat_messages"),
]
