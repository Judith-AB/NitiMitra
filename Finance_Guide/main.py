from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import PyPDF2
from sentence_transformers import SentenceTransformer
import faiss
import numpy as np
import re
from typing import List, Optional
import json

app = FastAPI()

# Add CORS middleware to allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------
# Load PDF and split into chunks with better processing
pdf_path = "indian_scholarships_compendium.pdf"
print("Loading PDF document...")
text = ""
try:
    with open(pdf_path, "rb") as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            text += page.extract_text() + "\n"
except FileNotFoundError:
    print(f"Error: PDF file '{pdf_path}' not found.")
    text = ""

def chunk_text(text, max_len=500):
    # Improved chunking to keep related content together
    paragraphs = text.split("\n\n")
    chunks = []
    current_chunk = ""
    
    for paragraph in paragraphs:
        paragraph = paragraph.strip()
        if not paragraph:
            continue
            
        if len(current_chunk) + len(paragraph) > max_len and current_chunk:
            chunks.append(current_chunk)
            current_chunk = paragraph
        else:
            if current_chunk:
                current_chunk += "\n\n" + paragraph
            else:
                current_chunk = paragraph
                
    if current_chunk:
        chunks.append(current_chunk)
        
    return chunks

chunks = chunk_text(text)
print(f"Created {len(chunks)} text chunks")

# --------------------
# Create embeddings locally
print("Loading embedding model...")
try:
    model = SentenceTransformer('all-MiniLM-L6-v2')
    print("Creating embeddings...")
    embeddings = model.encode(chunks, convert_to_numpy=True)
    
    # Store embeddings in FAISS
    dimension = embeddings.shape[1]
    index = faiss.IndexFlatL2(dimension)
    index.add(embeddings)
    print("Embeddings ready!")
except Exception as e:
    print(f"Error loading model or creating embeddings: {e}")
    # Create empty structures as fallback
    model = None
    embeddings = np.array([])
    index = faiss.IndexFlatL2(384)  # Default dimension for the model

# --------------------
# Helper function to extract structured scholarship information
def extract_scholarship_info(text_chunk):
    """Extract structured information from text chunks"""
    info = {
        "name": "",
        "eligibility": "",
        "amount": 0.0,
        "category": "General",
        "source_text": text_chunk[:200] + "..." if len(text_chunk) > 200 else text_chunk
    }
    
    # Try to extract scholarship name (look for lines that might be titles)
    lines = text_chunk.split('\n')
    for i, line in enumerate(lines):
        line = line.strip()
        if (len(line) < 100 and 
            any(keyword in line.lower() for keyword in ['scholarship', 'fellowship', 'grant', 'award']) and
            not line.lower().startswith('eligibility')):
            info["name"] = line
            break
    
    # Try to extract amount (look for currency symbols)
    amount_patterns = [
        r'₹\s*([\d,]+(?:\.\d{2})?)',
        r'Rs\.\s*([\d,]+(?:\.\d{2})?)',
        r'INR\s*([\d,]+(?:\.\d{2})?)',
        r'([\d,]+(?:\.\d{2})?)\s*(?:₹|Rs\.|INR)'
    ]
    
    for pattern in amount_patterns:
        match = re.search(pattern, text_chunk)
        if match:
            try:
                amount_str = match.group(1).replace(',', '')
                info["amount"] = float(amount_str)
                break
            except ValueError:
                pass
    
    # Extract eligibility information
    eligibility_keywords = ['eligibility', 'criteria', 'qualification', 'require']
    for i, line in enumerate(lines):
        if any(keyword in line.lower() for keyword in eligibility_keywords):
            # Take this line and the next few lines as eligibility info
            eligibility_text = line
            for next_line in lines[i+1:i+4]:
                if next_line.strip() and len(eligibility_text + next_line) < 300:
                    eligibility_text += " " + next_line
                else:
                    break
            info["eligibility"] = eligibility_text.strip()
            break
    
    return info

# --------------------
# FastAPI models
class Query(BaseModel):
    text: str

class ScholarshipRecommendation(BaseModel):
    name: str
    eligibility: str
    amount: float
    category: str
    source_text: str
    similarity_score: Optional[float] = None

class RecommendationResponse(BaseModel):
    recommendations: List[ScholarshipRecommendation]
    query: str

# --------------------
# API ENDPOINTS

@app.get("/")
def read_root():
    return {"message": "Scholarship Recommendation API is running. Go to /docs to test the /recommend endpoint."}

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "chunks_loaded": len(chunks),
        "embeddings_ready": embeddings.shape[0] > 0 if hasattr(embeddings, 'shape') else False
    }

@app.post("/recommend", response_model=RecommendationResponse)
async def recommend(query: Query):
    if not chunks or model is None:
        raise HTTPException(status_code=503, detail="Service not ready. Please check if PDF was loaded correctly.")
    
    try:
        # Embed query
        query_vec = model.encode([query.text], convert_to_numpy=True)
        distances, indices = index.search(query_vec, k=5)  # Get top 5 for better filtering
        
        recommendations = []
        for i, (distance, idx) in enumerate(zip(distances[0], indices[0])):
            if idx < len(chunks):  # Ensure index is valid
                chunk = chunks[idx]
                scholarship_info = extract_scholarship_info(chunk)
                
                # Only include chunks that look like actual scholarship information
                if (scholarship_info["name"] or 
                    any(keyword in chunk.lower() for keyword in ['scholarship', 'fellowship', 'grant'])):
                    
                    recommendations.append(ScholarshipRecommendation(
                        **scholarship_info,
                        similarity_score=float(1 / (1 + distance))  # Convert distance to similarity score
                    ))
        
        # If we didn't find good matches, return at least the top chunks
        if not recommendations and indices[0].size > 0:
            for idx in indices[0]:
                if idx < len(chunks):
                    chunk = chunks[idx]
                    scholarship_info = extract_scholarship_info(chunk)
                    recommendations.append(ScholarshipRecommendation(
                        **scholarship_info,
                        similarity_score=0.5  # Default score
                    ))
        
        return RecommendationResponse(
            recommendations=recommendations[:3],  # Return top 3
            query=query.text
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing request: {str(e)}")

@app.get("/chunks/{index}")
def get_chunk(index: int):
    """Debug endpoint to view specific chunks"""
    if index < 0 or index >= len(chunks):
        raise HTTPException(status_code=404, detail="Chunk not found")
    return {"chunk": chunks[index], "index": index}