from langchain.agents import initialize_agent, AgentType
from langchain.memory import ConversationBufferMemory
from langchain.schema import SystemMessage
from langchain_community.chat_models import ChatOpenAI
from langchain.tools import Tool
import asyncio
import traceback

from app.core.config import API_KEY
from app.chat.tools.rag_tool import RAGTool
from app.chat.tools.sleep_tool import SleepTool
from app.chat.tools.report_tool import ReportTool
from app.chat.utils.memory import get_memory

class ChatService:
    def __init__(self):
        self.llm = ChatOpenAI(
            openai_api_key=API_KEY,
            temperature=0.6,
            model="gpt-4"
        )

        # 도구 초기화
        self.rag_tool = RAGTool()
        self.sleep_tool = SleepTool()
        self.report_tool = ReportTool()
        
        # 사용자별 메모리 저장소
        self.memories = {}
    
    async def process_message(self, user_id: str, message: str) -> str:
        """
        사용자 메시지를 처리하여 응답을 생성합니다.
        
        Args:
            user_id: 사용자 ID
            message: 사용자 메시지
            
        Returns:
            str: 생성된 응답 메시지
        """
        try:
            # 사용자 메모리 가져오기 (없으면 생성)
            if user_id not in self.memories:
                self.memories[user_id] = get_memory(user_id)
            
            memory = self.memories[user_id]
            
            # 사용자 ID를 도구 함수에 함께 전달하기 위한 래퍼 함수
            def sleep_data_with_user_id(query: str) -> str:
                try:
                    return self.sleep_tool.get_sleep_data(query, user_id)
                except Exception as e:
                    print(f"Sleep data tool error: {str(e)}")
                    return f"수면 데이터 조회 중 오류가 발생했습니다: {str(e)}"

            # 도구 설정 - 동기 메서드 사용
            tools = [
                Tool(
                    name="RAG_Search",
                    func=self.rag_tool.search,
                    description="검색어와 관련된 PDF 문서 정보를 검색합니다. 수면에 관련된 학술적 정보를 찾을 때 유용합니다."
                )
                # Tool(
                #     name="Sleep_Data",
                #     func=sleep_data_with_user_id,
                #     description="사용자의 수면 데이터를 분석합니다. 사용자의 수면 패턴, 점수, 깊은 수면 시간 등을 확인할 때 유용합니다."
                # )
            ]
            
            # 시스템 메시지 설정
            system_message = SystemMessage(content=f"""
            당신은 사용자의 수면 건강을 돕는 전문 수면 상담 AI입니다. 
            사용자가 문의하는 수면 관련 질문에 대해 전문적이고 친절하게 답변해 주세요.
            사용자의 수면 데이터와 관련 학술 연구, 그리고 과거 생성된 리포트를 참조하여 맞춤형 조언을 제공합니다.
            불필요한 도구 사용은 지양하고, 질문의 맥락에 맞는 도구만 선택하여 효율적으로 정보를 검색하세요.
            정확한 정보를 제공하되, 의학적 진단이나 치료는 확실하지 않다면 제시하지 마세요.
            문장의 길이는 3줄로 제한하나, 사용자가 더 구체적이거나 긴 답변을 원할 경우 제한하지 않습니다.
            답변은 사용자가 읽기 쉬운 단어를 사용해주세요. 특히, 100단위가 넘는 시간 초는 시간/분으로 바꿔주세요.
            답변은 한국어로 해주세요.
            """ 
            )
            
            # 에이전트 초기화
            agent = initialize_agent(
                tools,
                self.llm,
                agent=AgentType.CHAT_CONVERSATIONAL_REACT_DESCRIPTION,
                verbose=True,
                memory=memory,
                handle_parsing_errors=True,
                system_message=system_message,
                max_iterations=5,  # 최대 도구 사용 횟수 제한
                # early_stopping_method="generate"  # 조기 종료 방법
            )
            
            # 비동기 컨텍스트에서 동기 함수 실행
            # FastAPI의 이벤트 루프에서 에이전트 실행
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(None, lambda: agent.run(input=message))
            
            print("agent에서 만든 대답:", response)
            print("agent에서 만든 대답의 타입:", type(response))
            
            return response
            
        except Exception as e:
            # 상세한 오류 로깅
            error_msg = f"Error processing message: {str(e)}"
            print(error_msg)
            print(traceback.format_exc())
            return f"죄송합니다. 메시지 처리 중 오류가 발생했습니다: {str(e)}"