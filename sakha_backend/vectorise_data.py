#!/usr/bin/env python
"""
vectorise_data.py

This script loads Bhagavad Gita related data from JSON files (authors, chapters, verse,
commentary, and translation), cleans and concatenates them into well-structured documents,
obtains vector embeddings using OpenAI’s text-embedding-ada-002 model, and stores them in a
Pinecone vector store.

Before running:
  - Ensure that the JSON files are placed in a folder (e.g. "data") in the project root.
  - Set the required environment variables:
       OPENAI_API_KEY, PINECONE_API_KEY, and PINECONE_ENV.
  - Install required dependencies:
       pip install pinecone-client langchain openai python-dotenv
"""

import os
import json
import logging
from pathlib import Path

import pinecone
import openai
from langchain.embeddings import OpenAIEmbeddings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def load_json_file(file_path: str):
    """Load JSON data from a file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        logger.info(f"Loaded data from {file_path} ({len(data)} records)")
        return data
    except Exception as e:
        logger.error(f"Error loading {file_path}: {e}")
        raise


def clean_text(text: str) -> str:
    """
    Clean the input text by stripping leading/trailing whitespace and reducing multiple
    spaces/newlines to a single space.
    """
    if not text:
        return ""
    return " ".join(text.strip().split())


def create_lookup_dict(data_list: list, key_field: str, value_field: str) -> dict:
    """Create a dictionary for quick lookup from a list of dictionaries."""
    return {str(item[key_field]): item.get(value_field, "") for item in data_list}


def main():
    # ========================
    # 1. Environment & Setup
    # ========================
    # Ensure necessary API keys and credentials are set.
    OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
    PINECONE_API_KEY = os.environ.get("PINECONE_API_KEY")
    PINECONE_ENV = os.environ.get("PINECONE_ENV")

    if not (OPENAI_API_KEY and PINECONE_API_KEY and PINECONE_ENV):
        logger.error("Please set OPENAI_API_KEY, PINECONE_API_KEY, and PINECONE_ENV in your environment.")
        return

    # Set OpenAI API key (used internally by LangChain)
    openai.api_key = OPENAI_API_KEY

    # Initialize Pinecone
    pinecone.init(api_key=PINECONE_API_KEY, environment=PINECONE_ENV)
    index_name = "geeta-index"
    embedding_dim = 1536  # Dimension for text-embedding-ada-002

    # Create the Pinecone index if it does not exist.
    if index_name not in pinecone.list_indexes():
        logger.info(f"Index '{index_name}' does not exist. Creating it now...")
        pinecone.create_index(index_name, dimension=embedding_dim, metric="cosine")
    else:
        logger.info(f"Index '{index_name}' already exists.")

    # Connect to the index.
    index = pinecone.Index(index_name)

    # ============================
    # 2. Load and Organize Data
    # ============================
    # Assume that the JSON files are located in a folder called "data" in the current directory.
    data_dir = Path(__file__).parent / "data"
    if not data_dir.exists():
        logger.error(f"Data directory '{data_dir}' does not exist.")
        return

    authors_file = data_dir / "authors.json"
    chapters_file = data_dir / "chapters.json"
    commentary_file = data_dir / "commentary.json"
    translation_file = data_dir / "translation.json"
    verse_file = data_dir / "verse.json"

    authors_data = load_json_file(authors_file)
    chapters_data = load_json_file(chapters_file)
    commentary_data = load_json_file(commentary_file)
    translation_data = load_json_file(translation_file)
    verses_data = load_json_file(verse_file)

    # Create lookup dictionaries for authors and chapters.
    authors_lookup = create_lookup_dict(authors_data, key_field="id", value_field="name")
    chapters_lookup = {str(chap["id"]): chap for chap in chapters_data}

    # Group commentary and translation entries by verse_id.
    commentary_lookup = {}
    for entry in commentary_data:
        verse_id = str(entry.get("verse_id"))
        commentary_lookup.setdefault(verse_id, []).append(entry)

    translation_lookup = {}
    for entry in translation_data:
        verse_id = str(entry.get("verse_id"))
        translation_lookup.setdefault(verse_id, []).append(entry)

    # ============================================
    # 3. Initialize the Embedding Model (LangChain)
    # ============================================
    embeddings_model = OpenAIEmbeddings(
        model="text-embedding-ada-002", openai_api_key=OPENAI_API_KEY
    )

    # ========================================
    # 4. Process, Clean, and Vectorise Data
    # ========================================
    batch_size = 100  # Adjust based on your requirements and rate limits.
    vectors_batch = []
    processed_count = 0

    for verse in verses_data:
        verse_id = str(verse.get("id"))
        # Clean the main fields from the verse.
        verse_text = clean_text(verse.get("text", ""))
        transliteration = clean_text(verse.get("transliteration", ""))
        word_meanings = clean_text(verse.get("word_meanings", ""))
        verse_title = clean_text(verse.get("title", ""))

        # Optionally add chapter summary from chapters data.
        chapter_info = chapters_lookup.get(str(verse.get("chapter_id")))
        chapter_summary = ""
        if chapter_info:
            # Prefer the English summary; adjust if you need the Hindi version.
            chapter_summary = clean_text(chapter_info.get("chapter_summary", ""))

        # Collate commentary texts.
        commentary_entries = commentary_lookup.get(verse_id, [])
        commentary_texts = []
        for entry in commentary_entries:
            # Use provided authorName or look it up.
            author_name = entry.get("authorName") or authors_lookup.get(str(entry.get("author_id")), "")
            commentary_texts.append(
                f"Commentary by {author_name}: {clean_text(entry.get('description', ''))}"
            )
        combined_commentary = " ".join(commentary_texts)

        # Collate translation texts.
        translation_entries = translation_lookup.get(verse_id, [])
        translation_texts = []
        for entry in translation_entries:
            author_name = entry.get("authorName") or authors_lookup.get(str(entry.get("author_id")), "")
            translation_texts.append(
                f"Translation by {author_name}: {clean_text(entry.get('description', ''))}"
            )
        combined_translation = " ".join(translation_texts)

        # Build a well-structured document. Labels help downstream retrieval to remain anchored.
        document_parts = [
            f"Title: {verse_title}",
            f"Verse Text: {verse_text}",
        ]
        if transliteration:
            document_parts.append(f"Transliteration: {transliteration}")
        if word_meanings:
            document_parts.append(f"Word Meanings: {word_meanings}")
        if combined_commentary:
            document_parts.append(f"Commentary: {combined_commentary}")
        if combined_translation:
            document_parts.append(f"Translation: {combined_translation}")
        if chapter_summary:
            document_parts.append(f"Chapter Summary: {chapter_summary}")

        document = "\n".join(document_parts)

        # Prepare metadata to be stored with the vector.
        metadata = {
            "verse_id": verse_id,
            "chapter_id": verse.get("chapter_id"),
            "chapter_number": verse.get("chapter_number"),
            "verse_number": verse.get("verse_number"),
            "title": verse_title,
        }

        # Get the embedding vector for this document.
        try:
            vector = embeddings_model.embed_query(document)
        except Exception as e:
            logger.error(f"Error generating embedding for verse {verse_id}: {e}")
            continue

        # Append the vector data in the format expected by Pinecone.
        vectors_batch.append({
            "id": f"verse-{verse_id}",
            "values": vector,
            "metadata": metadata,
        })
        processed_count += 1

        # Upsert in batches to respect API rate limits and improve efficiency.
        if len(vectors_batch) >= batch_size:
            try:
                logger.info(f"Upserting a batch of {len(vectors_batch)} vectors into Pinecone.")
                index.upsert(vectors=vectors_batch, namespace="geeta")
            except Exception as e:
                logger.error(f"Error upserting batch: {e}")
            vectors_batch = []

    # Upsert any remaining vectors.
    if vectors_batch:
        try:
            logger.info(f"Upserting final batch of {len(vectors_batch)} vectors into Pinecone.")
            index.upsert(vectors=vectors_batch, namespace="geeta")
        except Exception as e:
            logger.error(f"Error upserting final batch: {e}")

    logger.info(f"Completed processing. Total verses vectorised and upserted: {processed_count}")


if __name__ == "__main__":
    main()
