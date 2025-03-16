from langsmith import Client
from langchain.globals import set_debug, set_tracing_enabled
from langchain_community.chat_models import ChatOpenAI

from app.core.config import API_KEY, LANGSMITH_API_KEY

langsmith_client = Client(api_key=LANGSMITH_API_KEY)
llm = ChatOpenAI(model="gpt-3.5-turbo", tracing=True, api_key=API_KEY)

response = llm.invoke("Langsmith란 뭘까?")