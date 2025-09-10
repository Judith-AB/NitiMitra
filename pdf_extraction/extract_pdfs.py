import os
from pypdf import PdfReader

DATA_DIR = "data"
OUTPUT_FILE = "cleaned_text.txt"

def extract_from_pdf(pdf_path):
    reader = PdfReader(pdf_path)
    text = ""
    for page in reader.pages:
        page_text = page.extract_text() or ""
        text += page_text + "\n---PAGE BREAK---\n"
    return text

def clean_text(text):
    # remove unnecessary line breaks + extra spaces
    text = text.replace("\n", " ")
    text = " ".join(text.split())
    return text

def main():
    all_text = ""
    for file_name in os.listdir(DATA_DIR):
        if file_name.endswith(".pdf"):
            pdf_path = os.path.join(DATA_DIR, file_name)
            print(f"Extracting {file_name} ...")
            raw_text = extract_from_pdf(pdf_path)
            cleaned = clean_text(raw_text)
            all_text += f"\n\n### {file_name} ###\n\n{cleaned}\n"
    
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(all_text)
    print(f"\n✅ Done! Extracted text saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
