from sqlalchemy import Column, Integer, String, TIMESTAMP, func
from src.database import Base

class Chatroom(Base):
    __tablename__ = "chatrooms"

    chat_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    title = Column(String(100), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
