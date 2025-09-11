# build_index.py
import os
from dotenv import load_dotenv
from langchain_community.document_loaders.pdf import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

# Load .env
load_dotenv(".env")

api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise RuntimeError("❌ OPENAI_API_KEY not found in .env")

print("✅ Using API key starting with:", api_key[:7])

# Load PDF
loader = PyPDFLoader("indian_scholarships_compendium.pdf")
docs = loader.load()

# Split into chunks
splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)
chunks = splitter.split_documents(docs)

# Pass API key explicitly
embeddings = OpenAIEmbeddings(
    model="text-embedding-3-small",
    api_key=api_key
)

# Build FAISS index
vectorstore = FAISS.from_documents(chunks, embeddings)
vectorstore.save_local("scholarship_index")

print("✅ Scholarship index built and saved!")
