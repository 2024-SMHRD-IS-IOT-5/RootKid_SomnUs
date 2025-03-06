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
        ("system", "당신은 식사 메뉴 추천 프로입니다. 사용자의 상황에 적절한 메뉴를 딱 한개만 추천해주세요."),
        ("human", "{question}"),
        ("ai", """
        이 형식을 따라 주시고, 반드시 한 줄로만 출력해주세요.:
        "메뉴 이름" + 은 어때요? +"추천 이유"
        """)
    ])

    # LangChain 실행
    chain = prompt | llm
    response = chain.invoke({"question": question})  

    return response
