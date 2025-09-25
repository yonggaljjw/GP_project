from sqlalchemy.ext.asyncio import AsyncSession
from src.models import Chatroom

async def create_chatroom(db: AsyncSession, user_id: int, title: str):
    new_chatroom = Chatroom(user_id=user_id, title=title)
    db.add(new_chatroom)
    await db.commit()
    await db.refresh(new_chatroom)
    return new_chatroom
