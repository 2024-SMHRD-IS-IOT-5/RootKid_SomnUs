import os
from langchain_openai import ChatOpenAI  
from langchain_core.prompts import ChatPromptTemplate
from dotenv import load_dotenv


# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path)
api_key = os.getenv("OPENAI_API_KEY")

def chatbot(question):
    llm = ChatOpenAI(model_name="gpt-3.5-turbo", openai_api_key=api_key)  
    
    # 프롬프트 템플릿 설정
    prompt = ChatPromptTemplate.from_messages([
        ("system", "너는 여행 정보 전문가야. 여행지 추천을 전문으로 해."),
        ("human", "{question}"),
        ("ai", """
        please follow this format:
        ==========================
        title
        ==========================
        - response 1
        - explanation
        - response 2
        - explanation
        - response3
        - explanation
        """)
    ])

    # LangChain 실행
    chain = prompt | llm
    response = chain.invoke({"question": question})  

    print(response)

if __name__ == "__main__":
    user_question = input("여행 관련 질문을 입력하세요: ")
    chatbot(user_question)
