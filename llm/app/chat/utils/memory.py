from langchain.memory import ConversationBufferMemory
from langchain.schema import HumanMessage, AIMessage

def get_memory(user_id: str) -> ConversationBufferMemory:
    """
    사용자별 대화 메모리를 생성합니다.
    
    Args:
        user_id: 사용자 ID
        
    Returns:
        ConversationBufferMemory: 사용자의 대화 메모리
    """
    memory = ConversationBufferMemory(
        memory_key="chat_history",
        return_messages=True,
        input_key="input",
        output_key="output"
    )
    
    # 초기 환영 메시지 설정
    memory.chat_memory.add_message(
        HumanMessage(content="안녕하세요")
    )
    memory.chat_memory.add_message(
        AIMessage(content="안녕하세요! 수면 건강에 관한 질문이 있으시면 언제든지 물어보세요. 어떻게 도와드릴까요?")
    )
    
    return memory