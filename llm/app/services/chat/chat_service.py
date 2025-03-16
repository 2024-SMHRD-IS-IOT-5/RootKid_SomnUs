from typing import Dict, Any, Optional
from app.agent.agent import SleepAgent
from app.core.config import chatbot_config

class ChatService:
    """
    Service layer that interfaces between chat routes and the agent functionality.
    Responsible for initializing the agent and handling message processing.
    """
    
    def __init__(self):
        """Initialize the chat service with a configured agent."""
        self.agent = SleepAgent(chatbot_config)
    
    async def process_message(self, user_id: str, message: str, metadata: Optional[Dict] = None) -> Dict[str, Any]:
        """
        Process a user message through the agent and return the response.
        
        Args:
            user_id: Unique identifier for the user
            message: The user's message text
            metadata: Optional metadata about the request
            
        Returns:
            Dictionary containing the agent's response and any additional data
        """
        return await self.agent.process_message(user_id, message, metadata)
    
    def reset_conversation(self, user_id: str) -> bool:
        """
        Reset the conversation for a specific user.
        
        Args:
            user_id: The user's unique identifier
            
        Returns:
            Boolean indicating success
        """
        return self.agent.reset_conversation(user_id)