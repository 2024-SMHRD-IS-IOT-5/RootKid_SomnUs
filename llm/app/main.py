from fastapi import FastAPI
from app.api.report import router as report_router
from app.test.test import router as test_router
from app.api.chat import chat_router

app = FastAPI()

@app.get("/")
def read_root():
    return {"message" : "Hello From llm server"}

app.include_router(report_router, prefix="/chatbot/report")
app.include_router(test_router, prefix="/test")
app.include_router(chat_router, prefix="/chatbot/message")