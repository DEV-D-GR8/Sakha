import os
import redis
import json
import openai
import pinecone
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate

# Redis setup (using django-redis cache or direct redis client)
redis_client = redis.Redis.from_url(os.environ.get("REDIS_URL", "redis://127.0.0.1:6379/1"))

# MongoDB setup
from pymongo import MongoClient
MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/sakha_logs")
mongo_client = MongoClient(MONGO_URI)
mongo_db = mongo_client.get_default_database()  # Database name from URI
chat_logs_collection = mongo_db.chat_logs

# OpenAI API key
openai.api_key = os.environ.get("OPENAI_API_KEY")

# Pinecone initialization
pinecone_api_key = os.environ.get("PINECONE_API_KEY")
pinecone_env = os.environ.get("PINECONE_ENV")
if pinecone_api_key and pinecone_env:
    pinecone.init(api_key=pinecone_api_key, environment=pinecone_env)
    # Assume index name is fixed; adjust if needed.
    INDEX_NAME = "geeta-index"
else:
    raise Exception("Pinecone API key and environment must be set.")

def generate_chat_name(tenant_id: str, language: str = "en") -> str:
    """
    Generate a chat session name using OpenAI GPT-4o.
    The result is cached in Redis so that repeated calls (for the same tenant) can return a consistent name.
    """
    cache_key = f"chat_name:{tenant_id}"
    cached_name = redis_client.get(cache_key)
    if cached_name:
        return cached_name.decode("utf-8")

    prompt = (
        "Generate a creative, concise name for a chat session discussing Shrimad Bhagavad Gita verses. "
        "Ensure the name reflects wisdom and spirituality. "
        "Return only the name."
    )
    if language == "hi":
        prompt = (
            "श्रीमद् भगवद् गीता के श्लोकों पर आधारित चर्चा सत्र के लिए एक रचनात्मक और संक्षिप्त नाम उत्पन्न करें। "
            "नाम में ज्ञान और आध्यात्मिकता झलकनी चाहिए। केवल नाम लौटाएं।"
        )

    response = openai.ChatCompletion.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=20,
    )
    chat_name = response.choices[0].message["content"].strip()
    # Cache the generated name for 24 hours
    redis_client.setex(cache_key, 86400, chat_name)
    return chat_name

def get_retriever():
    """
    Set up a LangChain retriever using Pinecone.
    Assumes that your Bhagavad Gita vectors have been indexed in Pinecone.
    """
    from langchain.vectorstores import Pinecone as LC_Pinecone

    # The index and namespace must match your vectorized data.
    index = pinecone.Index(INDEX_NAME)
    vectorstore = LC_Pinecone(index, embedding_function=None, namespace="geeta")
    retriever = vectorstore.as_retriever(search_kwargs={"k": 4})
    return retriever

def generate_bot_response(user_query: str, chat_context: str, language: str = "en") -> str:
    """
    Use LangChain’s RetrievalQA chain with OpenAI GPT-4o to generate a response strictly in the context
    of Shrimad Bhagavad Gita. The output must include:
        - Shloka
        - Chapter and verse number
        - Meaning of the shloka
        - Answer to the user's query
    """
    retriever = get_retriever()
    # Use a custom prompt template to enforce the response format.
    if language == "hi":
        template = (
            "आपको निम्न श्लोकों के संदर्भ में उत्तर देना है: \n"
            "1. श्लोक (अंग्रेज़ी ट्रांस्लिटरेशन या हिंदी में),\n"
            "2. अध्याय और श्लोक संख्या,\n"
            "3. श्लोक का अर्थ,\n"
            "4. उपयोगकर्ता के प्रश्न का उत्तर।\n"
            "संदर्भ: {context}\n"
            "प्रश्न: {question}\n"
            "कृपया केवल उपरोक्त प्रारूप में उत्तर दें।"
        )
    else:
        template = (
            "You are to answer strictly in the context of Shrimad Bhagavad Gita. "
            "Provide your answer in the following format:\n"
            "1. Shloka,\n"
            "2. Chapter number and verse number for the shloka,\n"
            "3. Meaning of the shloka,\n"
            "4. Answer to the user's query.\n"
            "Context: {context}\n"
            "Question: {question}\n"
            "Please respond using only the above format."
        )

    prompt_template = PromptTemplate(template=template, input_variables=["context", "question"])

    # Configure the LLM (using GPT-4)
    llm = OpenAI(model_name="gpt-4o", temperature=0.5, max_tokens=500)
    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=retriever,
        chain_type_kwargs={"prompt": prompt_template},
    )

    # Run the chain with the chat context and the current user query.
    response = qa_chain.run(question=user_query, context=chat_context)
    return response.strip()

# Redis caching functions for chat context
def cache_chat_context(session_id: str, context: str, expiry: int = 3600):
    """
    Cache chat context (concatenated conversation history) for a given session.
    """
    cache_key = f"chat_context:{session_id}"
    redis_client.setex(cache_key, expiry, context)

def get_cached_chat_context(session_id: str) -> str:
    cache_key = f"chat_context:{session_id}"
    cached = redis_client.get(cache_key)
    if cached:
        return cached.decode("utf-8")
    return ""

# MongoDB function for storing chat logs
def store_chat_log_mongo(session_id: str, message_data: dict):
    """
    Store conversation logs in MongoDB for analytics or auditing.
    """
    record = {
        "session_id": session_id,
        "message": message_data,
    }
    chat_logs_collection.insert_one(record)
