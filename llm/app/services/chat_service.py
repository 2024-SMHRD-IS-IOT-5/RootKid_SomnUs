import os
import pickle
import faiss
import numpy as np
import datetime
from openai import OpenAI
from typing import List, Dict, Any
from langchain.prompts.chat import ChatPromptTemplate
from langchain.memory import ConversationBufferMemory
from app.core.config import API_KEY

# OpenAI 클라이언트 생성
client = OpenAI(api_key=API_KEY)

# 대화 메모리 설정
conversation_memory = ConversationBufferMemory(memory_key="history", return_messages=False)

# 프롬프트 템플릿 설정
prompt_template = ChatPromptTemplate.from_template(
    "오늘 날짜는 {date}입니다.\n\n"
    "### 역할 설정 ###\n"
    "당신은 수면 전문가입니다. 사용자의 수면 패턴, 습관, 건강 상태를 분석하고 수면의 질을 개선하기 위한 맞춤형 조언을 제공합니다."
    "사용자는 청소년으로, 학업때문에 충분한 잠을 자지 못해 저희 제품을 이용합니다.\n\n"
    "### 데이터 활용 지침 ###\n"
    "1. 사용자의 수면 데이터(수면 시간, 수면 효율, REM/비REM 단계, 수면 중 깨는 횟수 등)를 분석하세요.\n"
    "2. 사용자의 수면 패턴이 건강에 미치는 영향을 과학적 근거를 바탕으로 설명하세요.\n"
    "3. 최신 수면 연구와 의학 지식을 활용하여 개인화된 조언을 제공하세요.\n"
    "### 커뮤니케이션 스타일 ###\n"
    "1. 전문적이지만 이해하기 쉬운 언어를 사용하세요. 의학 용어를 사용할 경우 간단히 설명을 덧붙이세요.\n"
    "2. 공감적이고 지지적인 태도로 소통하세요.\n"
    "3. 과학적 사실에 기반하되, 위협적이거나 불안을 조성하는 방식으로 정보를 전달하지 마세요.\n"
    "4. 답변은 두개의 문장으로 제한하지만, 사용자가 긴 답변이나 자세한 설명을 요구할 때에만 제한을 해제합니다.\n\n"
    "### 대화 맥락 ###\n"
    "이전 대화 내역:\n{history}\n\n"
    "### 사용자 질문 ###\n"
    "사용자: {question}\n\n"
    "### 참고 자료 ###\n"
    "관련 의학 논문 및 사용자 수면 데이터:\n{context}\n\n"
    "위 정보를 종합하여 의학적으로 정확하고, 개인화된, 실행 가능한 조언을 제공하세요. 필요시 추가 검사나 전문의 상담이 필요한 경우 이를 권고하되, 불필요한 불안을 조성하지 마세요."
)

def generate_answer_with_context(prompt: str, documents: List[str]) -> str:
    """
    ChatPromptTemplate과 ConversationBufferMemory를 이용하여 최종 프롬프트를 구성하고,
    GPT-4를 사용하여 답변을 생성합니다.
    """
    history = conversation_memory.load_memory_variables({}).get("history", "")
    context = "\n".join(documents)
    
    # 현재 날짜를 구합니다.
    try:
        import pytz
        today_date = datetime.datetime.now(pytz.timezone('Asia/Seoul')).strftime('%Y-%m-%d')
    except ImportError:
        # pytz가 설치되어 있지 않은 경우 대체 방법
        # UTC+9 시간을 수동으로 계산
        utc_time = datetime.datetime.utcnow()
        kst_time = utc_time + datetime.timedelta(hours=9)
        today_date = kst_time.strftime('%Y-%m-%d')
    
    # 프롬프트 템플릿에 대화 이력, 질문, 문맥, 그리고 오늘 날짜를 채워 넣습니다.
    final_prompt = prompt_template.format(
        history=history, 
        question=prompt, 
        context=context, 
        date=today_date
    )
    
    try:
        # GPT-4 모델을 사용하여 응답 생성
        response = client.chat.completions.create(
            model="gpt-4-turbo",
            messages=[{"role": "user", "content": final_prompt}],
            temperature=0.7,
            max_tokens=1000
        )
        
        answer = response.choices[0].message.content
        
        # 대화 메모리에 저장
        conversation_memory.save_context({"question": prompt}, {"answer": answer})
        
        return answer
    
    except Exception as e:
        error_msg = f"LLM 응답 생성 중 오류 발생: {str(e)}"
        print(error_msg)
        return error_msg

class FaissVectorDB:
    def __init__(self, index, metadata, allow_dangerous_deserialization=False):
        self.index = index
        self.metadata = metadata
        self.allow_dangerous_deserialization = allow_dangerous_deserialization
    
    def query(self, prompt: str, top_k: int = 5) -> List[str]:
        """
        프롬프트를 임베딩하여 FAISS 인덱스를 검색한 후 상위 top_k 문서를 반환합니다.
        """
        vector = self.embed_prompt(prompt)
        distances, indices = self.index.search(vector, top_k)
        results = []
        for idx in indices[0]:
            if 0 <= idx < len(self.metadata):
                results.append(self.metadata[idx])
        return results
    
    def embed_prompt(self, prompt: str) -> np.ndarray:
        """
        OpenAI의 임베딩 모델을 사용하여 텍스트를 벡터로 변환합니다.
        한국어를 포함한 다국어를 지원하는 text-embedding-3-small 모델을 사용합니다.
        """
        try:
            response = client.embeddings.create(
                model="text-embedding-3-small",
                input=[prompt]
            )
            embedding_vector = np.array([response.data[0].embedding], dtype='float32')
            
            # FAISS 인덱스의 차원과 일치하지 않을 경우 예외 처리
            if embedding_vector.shape[1] != self.index.d:
                print(f"임베딩 차원 불일치: 생성된 {embedding_vector.shape[1]}차원, 인덱스는 {self.index.d}차원")
                # 차원이 맞지 않으면 0 벡터 반환 (긴급 폴백 전략)
                return np.zeros((1, self.index.d), dtype='float32')
            
            return embedding_vector
            
        except Exception as e:
            print(f"임베딩 생성 중 오류 발생: {str(e)}")
            # 오류 발생 시 0 벡터 반환 (폴백 전략)
            return np.zeros((1, self.index.d), dtype='float32')

def load_faiss_vector_db(directory: str) -> FaissVectorDB:
    """
    지정된 디렉토리(상대경로를 절대경로로 변환)에서 index.pkl과 index.faiss 파일을 로드합니다.
    allow_dangerous_deserialization 옵션을 활성화하여 메타데이터를 로드합니다.
    """
    try:
        abs_directory = os.path.abspath(directory)
        pkl_path = os.path.join(abs_directory, "index.pkl")
        index_path = os.path.join(abs_directory, "index.faiss")
        
        with open(pkl_path, "rb") as f:
            metadata = pickle.load(f)
        
        index = faiss.read_index(index_path)
        
        return FaissVectorDB(index, metadata, allow_dangerous_deserialization=True)
    
    except Exception as e:
        print(f"FAISS 벡터 DB 로드 중 오류 발생: {str(e)}")
        raise

# vector db load
vector_db = load_faiss_vector_db("app/faiss/")

def chat_with_user(prompt: str) -> str:
    """
    사용자의 프롬프트를 받아 FAISS DB에서 관련 문서를 검색하고,
    대화 이력을 포함한 프롬프트를 생성하여 GPT-4 기반 답변을 반환합니다.
    """
    try:
        documents = vector_db.query(prompt)
        answer = generate_answer_with_context(prompt, documents)
        return answer
    except Exception as e:
        error_msg = f"챗봇 응답 생성 중 오류 발생: {str(e)}"
        print(error_msg)
        return error_msg