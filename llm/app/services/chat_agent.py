from langchain.llms import OpenAI
from langchain.agents import initialize_agent, Tool, AgentType
from tools.sleep_data_tools import sleep_data_tools
from tools.embedded_tools import embedded_tools

# LLM 및 Tool 초기화
llm = OpenAI(temperature=0.5)
tools = [
    Tool.from_function(sleep_data_tools, name="query_sleep_data"),
    Tool.from_function(embedded_tools, name="search_sleep_knowledge"),
]

# LangChain AI Agent 초기화
agent = initialize_agent(tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True)

async def get_agent_response(user_input: str) -> str:
    """
    LangChain AI Agent를 사용하여 사용자의 자연어 입력에 대한 응답을 생성합니다.
    
    Args:
        user_input (str): 사용자가 입력한 채팅 메시지
    
    Returns:
        str: AI Agent가 생성한 응답 메시지
    """
    try:
        return await agent.run(user_input)
    except Exception as e:
        return f"오류 발생: {str(e)}"
