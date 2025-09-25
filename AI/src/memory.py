from langchain_elasticsearch import ElasticsearchChatMessageHistory
import os

ES_URL = f"http://{os.getenv('ES_HOST')}:{os.getenv('ES_PORT')}"


def get_memory(session_id: str):
    history = ElasticsearchChatMessageHistory(
        es_url=ES_URL,
        index="chat_history",
        session_id=session_id
    )
    return history
