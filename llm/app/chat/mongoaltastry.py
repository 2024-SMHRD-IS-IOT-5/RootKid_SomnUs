from langchain.agents import initialize_agent, AgentType
from langchain.memory import ConversationBufferMemory
from langchain.schema import SystemMessage
from langchain_community.chat_models import ChatOpenAI
from langchain.tools import Tool
from langchain_community.agent_toolkits import MongoDBToolkit
import asyncio
import traceback

from app.core.config import API_KEY
from app.chat.tools.rag_tool import RAGTool
from app.chat.utils.memory import get_memory

class ChatService:
    def __init__(self):
        self.llm = ChatOpenAI(
            openai_api_key=API_KEY,
            temperature=0.7,
            model="gpt-4"
        )
        
        # RAG 도구는 그대로 사용
        self.rag_tool = RAGTool()
        
        # MongoDBToolkit을 사용하여 각각의 컬렉션에 접근하는 도구 생성
        self.sleep_mongo_toolkit = MongoDBToolkit(
            mongodb_uri="your_mongodb_uri",
            db_name="your_db_name",
            collection_name="sleep_data"  # 수면 데이터가 저장된 컬렉션
        )
        self.report_mongo_toolkit = MongoDBToolkit(
            mongodb_uri="your_mongodb_uri",
            db_name="your_db_name",
            collection_name="report_data"  # 리포트 데이터가 저장된 컬렉션
        )
        
        # 사용자별 메모리 저장소
        self.memories = {}
    
    async def process_message(self, id: str, message: str) -> str:
        """
        사용자 메시지를 처리하여 응답을 생성합니다.
        """
        try:
            # 사용자 메모리 가져오기 (없으면 생성)
            if id not in self.memories:
                self.memories[id] = get_memory(id)
            memory = self.memories[id]
            
            # MongoDBToolkit에서 도구 가져오기 (각각 하나의 도구라고 가정)
            sleep_tool_raw = self.sleep_mongo_toolkit.get_tools()[0]
            report_tool_raw = self.report_mongo_toolkit.get_tools()[0]
            
            # 사용자 ID를 포함하도록 쿼리를 수정하는 래퍼 함수
            def sleep_data_with_user_id(query: str) -> str:
                try:
                    # 쿼리에 사용자 필터 추가 (필드 이름은 데이터 스키마에 맞게 조정)
                    modified_query = f"{query} AND id == '{id}'"
                    return sleep_tool_raw.func(modified_query)
                except Exception as e:
                    print(f"Sleep data tool error: {str(e)}")
                    return f"수면 데이터 조회 중 오류가 발생했습니다: {str(e)}"
            
            def report_search_with_user_id(query: str) -> str:
                try:
                    modified_query = f"{query} AND id == '{id}'"
                    return report_tool_raw.func(modified_query)
                except Exception as e:
                    print(f"Report search tool error: {str(e)}")
                    return f"리포트 검색 중 오류가 발생했습니다: {str(e)}"
            
            # 도구 설정
            tools = [
                Tool(
                    name="RAG_Search",
                    func=self.rag_tool.search,
                    description="검색어와 관련된 PDF 문서 정보를 검색합니다. 수면에 관련된 학술적 정보를 찾을 때 유용합니다."
                ),
                Tool(
                    name="Sleep_Data",
                    func=sleep_data_with_user_id,
                    description="사용자의 수면 데이터를 분석합니다. 수면 패턴, 점수, 깊은 수면 시간 등을 확인할 때 유용합니다."
                ),
                Tool(
                    name="Report_Search",
                    func=report_search_with_user_id,
                    description="사용자의 수면 리포트를 검색합니다. 일간, 주간, 월간 리포트를 확인할 때 유용합니다."
                )
            ]
            
            # 시스템 메시지 설정
            system_message = SystemMessage(content="""
            당신은 사용자의 수면 건강을 돕는 전문 수면 상담 AI입니다. 
            사용자가 문의하는 수면 관련 질문에 대해 전문적이고 친절하게 답변해 주세요.
            사용자의 수면 데이터와 관련 학술 연구, 그리고 과거 생성된 리포트를 참조하여 맞춤형 조언을 제공합니다.
            불필요한 도구 사용은 지양하고, 질문의 맥락에 맞는 도구만 선택하여 효율적으로 정보를 검색하세요.
            정확한 정보를 제공하되, 의학적 진단이나 치료를 직접 제시하지 마세요.
            """)
            
            # 에이전트 초기화 (최대 도구 사용 횟수 제한: 5)
            agent = initialize_agent(
                tools,
                self.llm,
                # agent=AgentType.CHAT_CONVERSATIONAL_REACT_DESCRIPTION,
                agent=AgentType.OPENAI_FUNCTIONS,
                verbose=True,
                memory=memory,
                handle_parsing_errors=True,
                system_message=system_message,
                max_iterations=5
            )
            
            # 비동기 컨텍스트에서 동기 함수 실행 (FastAPI 이벤트 루프 내)
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(None, lambda: agent.run(input=message))
            
            return response
            
        except Exception as e:
            error_msg = f"Error processing message: {str(e)}"
            print(error_msg)
            print(traceback.format_exc())
            return f"죄송합니다. 메시지 처리 중 오류가 발생했습니다: {str(e)}"
