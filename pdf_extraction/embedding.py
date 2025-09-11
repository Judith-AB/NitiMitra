import os
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer

# --- Init local embedding model ---
model = SentenceTransformer("all-MiniLM-L6-v2")

# --- Pinecone API key (hardcoded for now) ---
PINECONE_API_KEY = "pcsk_472Eg7_CRHN9xqpELn4h8ayR5fSYW8YFRbmjeB4whXj2hg14J65XMzwjnV7149uyLCqxYK"

if not PINECONE_API_KEY:
    raise ValueError("❌ PINECONE_API_KEY not found!")

# --- Init Pinecone client ---
pc = Pinecone(api_key=PINECONE_API_KEY)

index_name = "nitimitra"

# --- Create index if not exists ---
# --- Create index (delete old if mismatch) ---
if index_name in pc.list_indexes().names():
    pc.delete_index(index_name)  # ensures fresh index with correct dimensions

pc.create_index(
    name=index_name,
    dimension=384,  # match MiniLM
    metric="cosine",
    spec=ServerlessSpec(cloud="aws", region="us-east-1")
)


# --- Connect to index ---
index = pc.Index(index_name)

# --- Load cleaned text file ---
file_path = r"C:\Users\Gouri K\Desktop\projects\sakhi\NitiMitra\pdf_extraction\cleaned_text.txt"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# --- Split text into chunks ---
def chunk_text(text, chunk_size=300, overlap=50):
    words = text.split()
    chunks, start = [], 0
    while start < len(words):
        end = min(start + chunk_size, len(words))
        chunk = " ".join(words[start:end])
        chunks.append(chunk)
        start += chunk_size - overlap
    return chunks

chunks = chunk_text(content)

# --- Embed chunks + prepare vectors ---
vectors = []
for i, chunk in enumerate(chunks):
    embedding = model.encode(chunk).tolist()
    vectors.append({
        "id": f"doc-{i}",
        "values": embedding,
        "metadata": {"text": chunk}
    })

# --- Insert into Pinecone ---
index.upsert(vectors=vectors)

print(f"✅ Inserted {len(vectors)} chunks into Pinecone from cleaned_text.txt")
print("First chunk sample:", chunks[0][:200], "...")

