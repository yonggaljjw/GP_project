from fastapi import FastAPI
import asyncio
from src.router import router as chat_router

app = FastAPI()
app.include_router(chat_router, prefix="/api")