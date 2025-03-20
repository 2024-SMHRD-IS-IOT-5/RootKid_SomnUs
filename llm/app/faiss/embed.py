from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain_community.embeddings.openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

API_KEY="여기에 api key 입력"

import os
print("작업위치: ",os.getcwd())
data_path = os.path.abspath("app/faiss/data/")
print("Using data path:", data_path)  # 경로 확인

def embed_documents(route):
    pdf_files = [f for f in os.listdir(route) if f.endswith(".pdf")]
    txt_files = [f for f in os.listdir(route) if f.endswith(".txt")]
    
    if not pdf_files:
        print("No PDF files found.")
        return
    
    all_texts = []
    for pdf in pdf_files:
        loader = PyPDFLoader(os.path.join(route, pdf))
        documents = loader.load()
        
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1500, chunk_overlap=300)
        texts = text_splitter.split_documents(documents)
        all_texts.extend(texts)
        
        # TXT 파일 처리
    for txt in txt_files:
        loader = TextLoader(os.path.join(route, txt), encoding="utf-8")
        documents = loader.load()
        
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1500, chunk_overlap=300)
        texts = text_splitter.split_documents(documents)
        all_texts.extend(texts)
    
    embeddings = OpenAIEmbeddings(model="text-embedding-3-small", openai_api_key=API_KEY)
    vec_db = FAISS.from_documents(all_texts, embeddings)
    vec_db.save_local("app/faiss/")
    
    print(f"임베딩 완료! {len(all_texts)}개의 문서가 처리되었습니다.")
    
embed_documents(data_path)