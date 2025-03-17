import os
import faiss
import pickle
import numpy as np
import pdfplumber
from langchain.embeddings.openai import OpenAIEmbeddings

# FAISS 저장 경로 설정
FAISS_INDEX_PATH = "faiss_index"
DOCUMENT_STORE_PATH = "document_store.pkl"
PDF_FOLDER = "data"

# OpenAI 임베딩 모델 초기화
embedding_model = OpenAIEmbeddings(model="text-embedding-ada-002", openai_api_key="your_openai_api_key")

def extract_text_from_pdf(pdf_path):
    """PDF 파일에서 텍스트 추출"""
    with pdfplumber.open(pdf_path) as pdf:
        text = "\n".join(page.extract_text() for page in pdf.pages if page.extract_text())
    return text

def embed_documents():
    """로컬 PDF 문서를 벡터화하여 FAISS에 저장"""
    
    # PDF 폴더 확인
    if not os.path.exists(PDF_FOLDER):
        print(f"❌ PDF 폴더가 존재하지 않습니다: {PDF_FOLDER}")
        return

    # PDF 파일 목록 가져오기
    pdf_files = [f for f in os.listdir(PDF_FOLDER) if f.endswith(".pdf")]
    if not pdf_files:
        print("❌ PDF 파일이 없습니다. 문서를 추가하세요.")
        return

    document_store = {}
    vectors = []
    
    # PDF 파일을 순회하며 임베딩 수행
    for idx, pdf_file in enumerate(pdf_files):
        pdf_path = os.path.join(PDF_FOLDER, pdf_file)
        print(f"📄 Processing: {pdf_file}")

        # PDF에서 텍스트 추출
        text = extract_text_from_pdf(pdf_path)
        if not text:
            print(f"⚠️ {pdf_file}에서 텍스트를 추출할 수 없습니다.")
            continue
        
        # 문서 텍스트를 벡터로 변환
        embedding = np.array(embedding_model.embed_query(text)).astype("float32")

        # FAISS에 저장할 벡터 추가
        vectors.append(embedding)
        
        # 문서 ID와 원본 텍스트 저장
        document_store[idx] = text

    # FAISS 인덱스 생성 및 저장
    vector_dim = len(vectors[0])
    faiss_index = faiss.IndexFlatL2(vector_dim)
    faiss_index.add(np.array(vectors))

    # 저장 폴더 생성
    os.makedirs("faiss", exist_ok=True)

    # FAISS 인덱스 저장
    faiss.write_index(faiss_index, FAISS_INDEX_PATH)
    
    # 문서 매핑 정보 저장
    with open(DOCUMENT_STORE_PATH, "wb") as f:
        pickle.dump(document_store, f)

    print("✅ FAISS 인덱스 및 문서 저장 완료!")

if __name__ == "__main__":
    embed_documents()
