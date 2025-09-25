import asyncio
import json
from pathlib import Path
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent
from langchain_mcp_adapters.client import MultiServerMCPClient

load_dotenv()

model = ChatOpenAI(model="gpt-4o")

async def load_servers_config(file_path: str = "src/servers.json") -> dict:
    """servers.json 파일에서 MCP 서버 설정을 불러옴"""
    path = Path(file_path)
    if not path.exists():
        print(f"⚠️ {file_path} not found. No MCP servers will be loaded.")
        return {}
    with path.open("r", encoding="utf-8") as f:
        return json.load(f).get("mcpServers", {})


async def get_agent_and_client():
    """MCP 서버 설정을 불러와 Agent와 Client를 초기화"""
    try:
        servers = await load_servers_config()
        if not servers:
            print("⚠️ No MCP servers found. Using base model only.")
            return create_react_agent(model, []), None


        client = MultiServerMCPClient(servers)
        tools = await client.get_tools()
        if not tools:
            print("⚠️ No tools loaded from MCP servers. Using base model only.")
            return create_react_agent(model, []), client

        agent = create_react_agent(model, tools)
        return agent, client

    except Exception as e:
        print(f"⚠️ MCP connection failed: {e}")
        return create_react_agent(model, []), None