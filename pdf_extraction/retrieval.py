from sentence_transformers import SentenceTransformer
from pinecone import Pinecone, ServerlessSpec
import os

# --- Load model and connect to Pinecone ---
model = SentenceTransformer("all-MiniLM-L6-v2")
PINECONE_API_KEY = "pcsk_472Eg7_CRHN9xqpELn4h8ayR5fSYW8YFRbmjeB4whXj2hg14J65XMzwjnV7149uyLCqxYK"  # your key
pc = Pinecone(api_key=PINECONE_API_KEY)
index_name = "nitimitra"
index = pc.Index(index_name)

# --- Retrieval function ---
def retrieve(query, k=4):
    query_emb = model.encode(query).tolist()
    res = index.query(vector=query_emb, top_k=k, include_metadata=True)
    return [match['metadata'] for match in res['matches']]

# --- Prompt template ---
PROMPT_TEMPLATE = """
You are NitiMitra assistant. Use ONLY the documents provided to answer the user's question.

Documents:
{docs}

User question: {question}

Answer concisely, mention eligibility if relevant, and list sources as URLs or titles at the end. 
If the question is outside these documents, say you don't have verified info and direct to official portals.
"""

# --- Helper to format prompt ---
def format_prompt(retrieved_docs, user_question):
    docs_text = "\n\n".join(
        [f"{doc.get('filename', 'Document')}:\n{doc['text']}" for doc in retrieved_docs]
    )
    return PROMPT_TEMPLATE.format(docs=docs_text, question=user_question)

# --- Test ---
if __name__ == "__main__":
    query = "Eligibility for Atal Pension Yojana"
    retrieved = retrieve(query)
    prompt = format_prompt(retrieved, query)
    print(prompt[:200], "...\n")  # preview first 1000 chars
