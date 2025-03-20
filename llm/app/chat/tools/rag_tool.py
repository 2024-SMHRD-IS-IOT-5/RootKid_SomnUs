import os
import pickle
import faiss
from typing import List, Dict, Any
import numpy as np
from langchain_community.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.document_loaders import PyPDFLoader

from app.core.config import API_KEY

class RAGTool:
    def __init__(self):
        self.embeddings = OpenAIEmbeddings(model="text-embedding-3-small", openai_api_key=API_KEY)
        self.faiss_path = "app/faiss/index.faiss"
        self.pkl_path = "app/faiss/index.pkl"
        self.pdf_dir = "app/faiss/data"
        
        # FAISS 인덱스 로드
        self.load_faiss_index()
    
    def load_faiss_index(self):
        """FAISS 인덱스 로드"""
        try:
            # 기존 인덱스 파일이 있는 경우 로드
            if os.path.exists(self.faiss_path) and os.path.exists(self.pkl_path):
                self.vector_store = FAISS.load_local(
                    self.faiss_path.replace("index.faiss", ""),
                    self.embeddings,
                    "index",
                    allow_dangerous_deserialization=True
                )
                print("기존 FAISS 인덱스를 로드했습니다.")
            else:
                # 인덱스 파일이 없는 경우 새로 생성
                print("FAISS 인덱스 파일이 없어 새로 생성합니다.")
                self._create_index()
        except Exception as e:
            print(f"FAISS 인덱스 로드 중 오류 발생: {e}")
            # 오류 발생 시 새로 인덱스 생성 시도
            self._create_index()
    
    def _create_index(self):
        """PDF 문서로부터 새 인덱스 생성"""
        documents = []
        
        # PDF 파일 로드
        for file in os.listdir(self.pdf_dir):
            if file.endswith('.pdf'):
                pdf_path = os.path.join(self.pdf_dir, file)
                try:
                    loader = PyPDFLoader(pdf_path)
                    documents.extend(loader.load())
                    print(f"PDF 파일 로드: {file}")
                except Exception as e:
                    print(f"PDF 파일 '{file}' 로드 중 오류 발생: {e}")
        
        # 문서 분할
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1500,
            chunk_overlap=300
        )
        chunked_documents = text_splitter.split_documents(documents)
        
        # 벡터 스토어 생성
        self.vector_store = FAISS.from_documents(chunked_documents, self.embeddings)
        
        # 인덱스 저장
        self.vector_store.save_local(self.faiss_path.replace("index.faiss", ""), "index")
        print("새 FAISS 인덱스를 생성하고 저장했습니다.")
    
    def search(self, query: str) -> str:
        """
        쿼리와 관련된 PDF 문서 정보를 검색합니다.
        
        Args:
            query: 검색 쿼리
            
        Returns:
            str: 검색 결과 문자열
        """
        try:
            # 관련 문서 검색 (상위 8개)
            results_with_scores = self.vector_store.similarity_search_with_score(query, k=8)
            
            # 관련성 점수 특정 값 이상만 필터링
            filtered_results = [doc for doc, score in results_with_scores if score > 0.8]
            
            results = filtered_results[:5]
            
            if not results:
                return "관련된 정보를 찾을 수 없습니다."
            
            # 결과 형식화
            result_str = "PDF 문서 검색 결과:\n\n"
            
            for i, doc in enumerate(results):
                result_str += f"문서 {i+1}:\n"
                result_str += f"{doc.page_content}\n"
                result_str += f"출처: {doc.metadata.get('source', '알 수 없음')}, 페이지: {doc.metadata.get('page', '알 수 없음')}\n\n"
            
            return result_str
        
        except Exception as e:
            print(f"PDF 검색 중 오류 발생: {e}")
            return f"검색 중 오류가 발생했습니다: {str(e)}"