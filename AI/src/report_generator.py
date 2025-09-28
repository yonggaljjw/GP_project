import json
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pymysql

from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_mcp_adapters.client import MultiServerMCPClient

# ------------------------
# 환경변수 로드
# ------------------------
load_dotenv()

# ------------------------
# DB에서 군집데이터 읽어오기
# ------------------------
engine = create_engine(
    f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
cluster_data = pd.read_sql("SELECT * FROM cluster_data1", engine)

# ------------------------
# 모델 초기화
# ------------------------
model = ChatOpenAI(model="gpt-4o")


# ------------------------
# MCP 서버 설정 로드
# ------------------------
async def load_servers_config(file_path: str = "src/report_server.json") -> dict:
    path = Path(file_path)
    if not path.exists():
        return {}

    with path.open("r", encoding="utf-8") as f:
        return json.load(f).get("mcpServers", {})


# ------------------------
# 단계 1: 데이터 분석
# ------------------------
async def analyze_data(df: pd.DataFrame):
    prompt = ChatPromptTemplate.from_template(
        """
        너는 데이터 분석가다.

        [데이터 설명]
        - 독립변수: {columns}
        - 데이터 샘플: {sample}

        [요청]
        - Cluster별 지역적 특성과 주요 지표 특징을 정리할 것
        - 각 Cluster를 해석하여 '금융취약지역 후보' 여부를 도출할 것
        - 최종 반환은 반드시 JSON 배열 형식만 출력하라.
        """
    ).partial(
        columns=list(df.columns),
        sample=df.to_dict()  # 전체 대신 샘플만 전달 (토큰 절약)
    )

    response = await model.ainvoke(prompt.format())
    result_message = response.content.replace("```json","").replace("```","").strip()
    print(result_message)
    return result_message


# ------------------------
# 단계 2: MCP 보조 호출 (DeepResearch + Kakao Navigation with Distance)
# ------------------------
async def enrich_with_mcp(candidates: str, base_location: str = "서울역"):
    servers = await load_servers_config()
    if not servers:
        return candidates

    client = MultiServerMCPClient(servers)
    tools = await client.get_tools()

    deep_tool = next((t for t in tools if t.name == "DeepResearchMCP"), None)
    nav_tool = next((t for t in tools if t.name == "kakao-navigation-mcp-server"), None)

    results = []
    parsed = json.loads(candidates)

    for cand in parsed:
        region = cand.get("region")

        # DeepResearchMCP 호출
        if deep_tool:
            deep_res = await client.run_tool(
                "DeepResearchMCP",
                {"query": f"{region} 지역의 금융 취약성 및 사회경제적 특징"}
            )
            cand["deep_research"] = deep_res.get("output", "N/A")

        # Kakao Navigation MCP 호출 → 거리/시간 포함
        if nav_tool:
            nav_res = await client.run_tool(
                "kakao-navigation-mcp-server",
                {"origin": base_location, "destination": region}
            )
            cand["navigation_info"] = nav_res.get("output", "N/A")

        results.append(cand)

    print(results)
    return json.dumps(results, ensure_ascii=False)


# ------------------------
# 단계 3: Sequential Thinking + 최종 보고서 작성
# ------------------------
async def generate_report(enriched_data: str):
    servers = await load_servers_config()
    client = None
    seq_result = None

    if servers:
        client = MultiServerMCPClient(servers)
        tools = await client.get_tools()
        seq_tool = next((t for t in tools if t.name == "mcp-sequentialthinking-tools"), None)

        if seq_tool:
            seq_output = await client.run_tool(
                "mcp-sequentialthinking-tools",
                {
                    "input": (
                        "은행 이동점포 운영계획을 위한 순차적 사고를 해줘. "
                        "특히 거리와 이동시간, 금융취약성을 모두 고려해 최적의 방문 순서를 설계해줘. "
                        f"데이터: {enriched_data}"
                    )
                }
            )
            seq_result = seq_output.get("output", "")

    # 보고서 프롬프트
    prompt = ChatPromptTemplate.from_template(
        """
        너는 '은행 이동점포 운영 계획 일정' 보고서를 작성하는 전문 어시스턴트다.

        [분석 결과 + MCP 보강 데이터]
        {enriched}

        [순차적 사고 결과]
        {seq}

        [요청]
        - 기업 보고서 형식(마크다운)으로 작성.
        - 반드시 '방문 순서, 지역명, 근거(금융취약성 + 거리/이동시간)'를 포함할 것.
        - 문단은 [개요] [분석 요약] [지역별 운영 전략 제안] [결론] 으로 구분할 것.
        """
    ).partial(
        enriched=enriched_data,
        seq=seq_result or "순차적 사고 결과 없음"
    )

    response = await model.ainvoke(prompt.format())

    print(response)
    return response.content

# ------------------------
# 전체 파이프라인 실행
# ------------------------
async def full_pipeline():
    # 1단계: 데이터 분석
    candidates = await analyze_data(cluster_data)

    # 2단계: MCP 보강
    enriched = await enrich_with_mcp(candidates)

    # 3단계: Sequential Thinking + 보고서 생성
    report = await generate_report(enriched)

    return report
