# Sakha: AI-powered Wisdom from Shrimad Bhagavad Gita

Sakha is a **multitenant RAG based generative AI iOS application** that provides answers strictly in the context of the **Shrimad Bhagavad Gita** using **Retrieval-Augmented Generation (RAG)**. Users can interact with Sakha in either **Hindi or English**, and their conversations are persisted to allow seamless continuation.

Sakha integrates multiple technologies, including **Django, OpenAI GPT-4o, Langchain, Firebase authentication, Pinecone (vector store), Redis (cache), PostgreSQL, and MongoDB**. The backend is deployed on **AWS (ECS Fargate, API Gateway, RDS, ElastiCache, and Terraform-managed infrastructure)** with **CI/CD automation via Jenkins**.

## Tech Stack

### **Backend**
- **Frameworks:** Django, FastAPI, Langchain
- **AI Integration:** OpenAI GPT-4o
- **Vector Database:** Pinecone
- **Database:** PostgreSQL (RDS), MongoDB
- **Cache:** Redis (ElastiCache)
- **Authentication:** Firebase
- **Cloud Infrastructure:** AWS (ECS Fargate, API Gateway, CloudFront)
- **CI/CD:** Jenkins, Terraform

### **Frontend**
- **Platform:** iOS (Swift, SwiftUI)
- **Architecture:** MVVM (Model-View-ViewModel)
- **UI Components:** Custom chat interface, Dynamic chat list, Markdown parsing
- **Animations & UX Enhancements:** Smooth transitions, Typing indicators
- **Storage:** Firebase Authentication, Secure user data persistence

## Features

- **Shrimad Bhagavad Gita-based AI chatbot**
  - Generates responses strictly based on Bhagavad Gita’s teachings
  - Provides the **Shloka (in Sanskrit)**, **Chapter & Verse number**, **Meaning**, and **Answer**
  - Multi-language support: **English & Hindi**
  - AI-generated **conversation names**
- **Chat persistence**
  - Users can continue their chats seamlessly with context retention
- **Firebase authentication**
  - Secure user authentication using Firebase
- **Fast and scalable backend**
  - Uses Redis for caching
  - Stores vectorized Bhagavad Gita data in Pinecone
- **AWS Deployment**
  - ECS (Fargate) + API Gateway for serverless scaling
  - PostgreSQL (RDS) & MongoDB for structured and unstructured data
  - ElastiCache (Redis) for performance optimization
  - CI/CD via Jenkins for automated deployments
- **Infrastructure as Code (IaC)**
  - Managed with Terraform
- **iOS App Features**
  - Interactive chat interface with Markdown parsing
  - Smooth and intuitive UX with SwiftUI animations
  - User profile management and chat history
  - Secure storage and Firebase-based authentication

## Demo Video

[Watch the Demo on YouTube](https://youtu.be/Z5c3ISRnX00?si=e8sC_ioPymUihz2R)
