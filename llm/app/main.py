from fastapi import FastAPI
from app.api.chat import router as chat_router
from app.api.report import router as report_router
from app.test.test import router as test_router


app = FastAPI()

@app.get("/")
def read_root():
    return {"message" : "Hello From llm server"}

app.include_router(chat_router)
app.include_router(report_router)
app.include_router(test_router, prefix="/test")