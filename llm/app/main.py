from fastapi import FastAPI
from app.api.chat import router as chat_router
from app.api.report import router as report_router

app = FastAPI()

app.include_router(chat_router, prefix="/chatbot/message")
app.include_router(report_router, prefix="/chatbot/receive-report")

# @app.get("/")
# def read_root():
#     return {"message" : "Hello From llm server"}