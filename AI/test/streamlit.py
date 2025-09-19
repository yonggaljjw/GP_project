import streamlit as st
import asyncio
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.agent import run_query

st.title("Multi MCP Agent 테스트")

user_input = st.text_input("질문을 입력하세요")

if st.button("실행") and user_input:
    with st.spinner("에이전트 실행 중..."):
        result = asyncio.run(run_query(user_input))
        st.write("### 결과")
        # content만 출력
        st.write(result)