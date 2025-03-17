import faiss
import numpy as np
import pickle
from langchain.tools import BaseTool
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain_community.chat_models import ChatOpenAI
from typing import Optional, Type
from pydantic import BaseModel, Field

from app.core.config import API_KEY

# OpenAI 임베딩 모델 및 LLM 초기화
# text-embedding-ada-002는 가성비가 좋고 장문에서도 쓸만한 모델이라고 함.
embedding_model = OpenAIEmbeddings(model="text-embedding-ada-002", openai_api_key=API_KEY)
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key=API_KEY)

# FAISS 인덱스 및 문서 매핑 로드
FAISS_INDEX_PATH = "../faiss/faiss_index"
DOCUMENT_STORE_PATH = "../faiss/document_store.pkl"

# FAISS 인덱스 로드
faiss_index = faiss.read_index(FAISS_INDEX_PATH)

# 문서 ID와 실제 텍스트를 매핑하는 딕셔너리 로드
with open(DOCUMENT_STORE_PATH, "rb") as f:
    document_store = pickle.load(f)

class VectorSearchInput(BaseModel):
    query: str = Field(..., description="사용자가 검색하려는 질문")

class VectorSearchTool(BaseTool):
    name = "VectorSearch"
    description = "벡터 임베딩된 학술자료를 검색하여, 질문과 관련된 정보를 반환합니다."
    args_schema: Type[BaseModel] = VectorSearchInput

    def _run(self, query: str) -> str:
        """
        주어진 질문을 벡터화하여 FAISS 인덱스에서 검색하고, 관련 학술자료를 반환하는 메서드.

        Args:
            query (str): 사용자 질문

        Returns:
            str: 검색된 학술자료를 기반으로 한 AI 응답
        """
        try:
            # 사용자 질문을 벡터화
            query_vector = np.array(embedding_model.embed_query(query)).astype("float32").reshape(1, -1)

            # FAISS를 이용해 가장 유사한 학술자료 검색 (상위 3개)
            top_k = 3
            distances, indices = faiss_index.search(query_vector, top_k)

            # 검색된 문서 가져오기
            retrieved_docs = [document_store[idx] for idx in indices[0] if idx in document_store]

            # 검색된 문서들을 하나의 텍스트로 조합
            context = "\n\n".join(retrieved_docs)

            # LLM에게 학술자료를 참고하여 최종 응답 생성 요청
            prompt = f"""
            다음은 사용자의 질문과 가장 관련 있는 학술자료입니다:
            {context}

            사용자 질문: "{query}"
            위의 자료를 참고하여, 질문에 대한 최적의 답변을 제공하세요.
            """
            response = llm.predict(prompt)

            return response

        except Exception as e:
            return f"VectorSearchTool 실행 중 오류 발생: {str(e)}"
