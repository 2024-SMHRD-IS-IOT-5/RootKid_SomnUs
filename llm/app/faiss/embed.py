from text_splitter import text_splitter
from langchain_community.document_loaders import PyPDFLoader
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

from app.core.config import API_KEY

def embed_documents(route):
    loader= PyPDFLoader(route)
    document = loader.load()
    
    # chunk로 분리
    texts = text_splitter(document)
    
    # 임베딩
    embeddings = OpenAIEmbeddings(model="text-embedding-ada-002", openai_api_key=API_KEY)
    vec_db = FAISS.from_documents(texts, embeddings)
    vec_db.save_local("")

if __name__ == "__main__":
    embed_documents("./data/")
