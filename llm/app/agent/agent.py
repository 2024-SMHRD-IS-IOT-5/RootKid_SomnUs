from langchain.agents import AgentExecutor, create_react_agent
from langchain.prompts import PromptTemplate
from langchain.tools import BaseTool
from langchain.memory import ConversationBufferMemory
from langchain.llms import OpenAI
from typing import List, Dict, Any, Optional
import logging

# Import config
from app.core.config import API_KEY

# Import custom tools
from tools.db_tool import SleepDataTool
from tools.vector_search_tool import VectorSearchTool

# Import prompts
from llm.app.template.agent_template import SLEEP_AGENT_SYSTEM_PROMPT

logger = logging.getLogger(__name__)

class SleepAgent:
    """
    AI Agent specialized for sleep data analysis and recommendations.
    Uses ReAct framework for reasoning and acting based on user queries.
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize the Sleep Agent with necessary tools and configurations.
        
        Args:
            config: Configuration dictionary with API keys, model params, etc.
        """
        self.config = config
        self.llm = OpenAI(
            temperature=config.get("agent_temperature", 0.2),
            model_name=config.get("agent_model", "gpt-4"),
            max_tokens=config.get("agent_max_tokens", 1500)
        )
        
        # 대화내용 저장.
        # ConversationBufferMemory는 대화내용 저장은 잘하는데,
        # 죄다 저장하는지라 token을 많이 쳐먹는다.
        # 그게 걱정된다면 ConversationSummaryMemory나 
        # ConversationBufferWindowMemory가 낫다.
        # 근데 지금은 발표할거라 최대한 성능 좋은거쓸거임 ㅋㅋ
        self.memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True,
            output_key="output"
        )
        
        # Initialize tools
        self.tools = self._initialize_tools()
        
        # Create the agent
        self.agent = self._create_agent()
        
        # Create the agent executor
        self.agent_executor = AgentExecutor.from_agent_and_tools(
            agent=self.agent,
            tools=self.tools,
            memory=self.memory,
            verbose=config.get("verbose", False),
            handle_parsing_errors=True,
            max_iterations=config.get("max_iterations", 3),
            max_execution_time=config.get("max_execution_time", 20),
            early_stopping_method="generate"
        )
    

    def _initialize_tools(self) -> List[BaseTool]:
        """
        에이전트가 사용할 수 있는 도구들을 초기화하고 반환합니다.
        
        Returns:
            List[BaseTool]: 에이전트가 사용할 도구 목록
        """
        # 수면 데이터 도구 - 일별, 주간/월간 데이터 접근
        db_tool = SleepDataTool(
            db_connection_string=self.config.get("db_connection_string"),
            db_name=self.config.get("db_name"),
            daily_collection="processing_sleep",
            aggregated_collection="sleep",
            reports_collection="reports"  # 필요하지 않으면 나중에 제거 가능
        )
        
        # 학술 정보 검색 도구
        vector_tool = VectorSearchTool(
            index_path = "sleep_knowledge_index",
            documents_path = "sleep_documents.pkl",
            embedding_model_name = "all-MiniLM-L6-v2"
        )
        
        # 앞으로 필요한 도구만 여기에 추가
        
        return [db_tool, vector_tool]
    
    def _create_agent(self):
        """Create and return the ReAct agent."""
        prompt = PromptTemplate.from_template(SLEEP_AGENT_SYSTEM_PROMPT)
        
        return create_react_agent(
            llm=self.llm,
            tools=self.tools,
            prompt=prompt
        )
    
    async def process_message(self, user_id: str, message: str, metadata: Optional[Dict] = None) -> Dict[str, Any]:
        """
        Process user message and return the agent's response.
        
        Args:
            user_id: Unique identifier for the user
            message: The user's message text
            metadata: Optional metadata about the request
            
        Returns:
            Dictionary containing the agent's response and any additional data
        """
        logger.info(f"Processing message for user {user_id}: {message[:50]}...")
        
        # Add user context to the input
        input_data = {
            "input": message,
            "user_id": user_id
        }
        
        try:
            # Execute the agent
            response = await self.agent_executor.ainvoke(input_data)
            
            logger.info("agent response generated!!")
            
            return {
                "response": response["output"],
                "thought_process": response.get("intermediate_steps", []),
                "status": "success"
            }
        except Exception as e:
            logger.error(f"Error processing message: {str(e)}")
            return {
                "response": "I'm sorry, I encountered an error while processing your request.",
                "error": str(e),
                "status": "error"
            }

# ReAct 
# Reasoning + Acting 으로, 
# 질문을 이해하고, 논리적으로 추론한 뒤, 적절한 도구를 실행한다는 말임.
# Zero-Shot ReAct
# 이번에 사용할 ReAct 타입.
# 에이전트가 사전 학습 없이 즉석으로(Zero-Shot) ReAct하는 방식.
# 다른 방식으로는 Few-Shot이 있는데,
# 도구 선택을 위한 몇 가지 예제를 제공하는 방식이다.
# Zero-Shot 은 더 빠르고, Few-Shot은 더 정확함.
# 일단 Zero-Shot으로 먼저 사용해보고, 정확성이 떨어진다면 Few-Shot을 사용해보자.
# 다만, 채팅은 응답속도도 중요하기에 속도와 정확성의 밸런싱도 중요한 문제다.
