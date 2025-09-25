from langchain_openai import ChatOpenAI

title_model = ChatOpenAI(model="gpt-4o-mini")

async def generate_title(first_message: str) -> str:
    prompt = f"""
    사용자의 첫 메시지를 15자 이내의 대화방 제목으로 요약해줘.
    불필요한 따옴표, 특수문자 없이 간단히 작성.
    메시지: "{first_message}"
    """
    resp = await title_model.ainvoke(prompt)
    return resp.content.strip()