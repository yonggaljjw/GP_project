from fastapi import FastAPI
from src.agent import run_query
import asyncio

app = FastAPI()

@app.get("/query")
async def query_agent(q: str):
    result = await run_query(q)
    return {"query": q, "result": result}
