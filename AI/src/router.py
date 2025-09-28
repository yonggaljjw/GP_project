from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from src.agent import get_agent_and_client
from src.memory import get_memory
from src.title_generator import generate_title
from src.database import AsyncSessionLocal
from src.crud import create_chatroom
from src.report_generator import full_pipeline

from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage, BaseMessage
from langchain_core.runnables import RunnableLambda

router = APIRouter()

# --- DB 의존성 ---
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

# --- 요청 모델 ---
class ChatRequest(BaseModel):
    user_id: int
    chat_id: int
    message: str

class ChatroomCreateRequest(BaseModel):
    user_id: int
    first_message: str

# --- 시스템 프롬프트 ---
SYSTEM_PROMPT = """
당신은 사용자의 대화를 이어가는 어시스턴트입니다.

규칙:
1. 반드시 최근 대화 맥락을 고려해서 답변하세요.
2. 사용자가 '그럼', '~도', '또 알려줘' 같은 연결 표현을 쓰면
   직전 대화 주제를 이어서 해석하세요.
3. 현재 대화가 특정 주제(예: 날씨)라면,
   새로운 지명이나 키워드가 등장했을 때 동일 주제로 이어서 답변하세요.
   (예: "내일 서울 상암동 날씨 알려줘" → "그럼 강남구는?" = 내일 강남구 날씨)
4. 새로운 주제로 전환임이 명확할 경우에만 독립적으로 응답하세요.
"""

# --- 히스토리와 신규 메시지를 합쳐서 agent가 기대하는 입력 형식으로 변환 ---
def _merge_history_and_input(inp: dict):
    history = inp.get("chat_history", [])
    new_msgs = inp.get("messages", [])
    return {"messages": [*history, *new_msgs]}

# --- 공통: 에이전트 + 병합 전처리 + 히스토리 래퍼 구성 함수 ---
async def _build_agent_with_history():
    agent, _ = await get_agent_and_client()

    merge = RunnableLambda(_merge_history_and_input)

    runnable = merge | agent

    wrapped = RunnableWithMessageHistory(
        runnable,
        lambda session_id: get_memory(session_id),  # 명시적으로 session_id 처리
        input_messages_key="messages",
        history_messages_key="chat_history"
    )
    return wrapped


# --- 채팅방 생성 ---
@router.post("/chatroom/create")
async def create_chatroom_api(req: ChatroomCreateRequest, db: AsyncSession = Depends(get_db)):
    # 제목 생성
    title = await generate_title(req.first_message)

    # MySQL 저장
    chatroom = await create_chatroom(db, req.user_id, title)

    # 세션 id
    session_id = f"{req.user_id}_{chatroom.chat_id}"

    # Agent 불러오기
    agent, _ = await get_agent_and_client()

    # 첫 메시지 (SystemPrompt 포함 권장)
    input_messages = [
        SystemMessage(content=SYSTEM_PROMPT),
        HumanMessage(content=req.first_message)
    ]

    # 응답 받기
    result = await agent.ainvoke({"messages": input_messages})

    # 결과 메시지 추출
    if isinstance(result, BaseMessage):
        ai_response = result.content
        ai_msg = result
    elif isinstance(result, dict) and "messages" in result:
        ai_msg = result["messages"][-1]
        ai_response = getattr(ai_msg, "content", str(ai_msg))
    else:
        ai_response = str(result)
        ai_msg = AIMessage(content=ai_response)

    # --- 히스토리에 저장 ---
    memory = get_memory(session_id)
    await memory.aadd_messages([HumanMessage(content=req.first_message)])
    await memory.aadd_messages([ai_msg if "ai_msg" in locals() else AIMessage(content=ai_response)])

    return {
        "chat_id": chatroom.chat_id,
        "title": chatroom.title,
        "first_message": req.first_message,
        "first_response": ai_response
    }


# --- 대화 API ---
@router.post("/chat")
async def chat(req: ChatRequest):
    session_id = f"{req.user_id}_{req.chat_id}"

    agent_with_history = await _build_agent_with_history()

    input_messages = [
        SystemMessage(content=SYSTEM_PROMPT),
        HumanMessage(content=req.message)
    ]

    result = await agent_with_history.ainvoke(
        {"messages": input_messages},
        config={"configurable": {"session_id": session_id}}
    )

    if isinstance(result, BaseMessage):
        ai_response = result.content
    elif isinstance(result, dict) and "messages" in result:
        ai_response = result["messages"][-1].content
    else:
        ai_response = str(result)

    return {
        "chat_id": req.chat_id,
        "message": req.message,
        "response": ai_response
    }


@router.get("/chatroom/history/{user_id}/{chat_id}")
async def get_chat_history(user_id: int, chat_id: int):
    session_id = f"{user_id}_{chat_id}"
    memory = get_memory(session_id)

    # 메모리 구현체가 async 기반이라면 aget_messages() 필요할 수 있음
    history = getattr(memory, "messages", None)
    if history is None and hasattr(memory, "aget_messages"):
        history = await memory.aget_messages()

    return [
        {"role": msg.type, "content": msg.content}
        for msg in history
    ]

@router.post("/report")
async def generator_report():

    report = await full_pipeline()
    return {"report": report}
