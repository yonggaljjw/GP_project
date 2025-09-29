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
from langchain.output_parsers import PydanticOutputParser
from pydantic import BaseModel
from typing import List

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
# 단계 1: 데이터 분석
# ------------------------
class AnalyzeResult(BaseModel) :
    region : str
    features : str
    score : int

class AnalyzeResults(BaseModel):
    results: List[AnalyzeResult]

parser = PydanticOutputParser(pydantic_object=AnalyzeResults)

async def analyze_data(df: pd.DataFrame, batch_size: int = 50):
    results: List[AnalyzeResult] = []

    for i in range(0, len(df), batch_size):
        batch = df.iloc[i:i+batch_size]

        # 프롬프트 정의
        prompt = ChatPromptTemplate.from_template(
            """
            너는 데이터 분석가다.  
            목표는 "은행 이동점포 운영계획" 수립을 위한 기초 분석이다.  

            [데이터 설명]  
            - 독립변수: {columns}  
            - 데이터 샘플(이 배치에 포함된 시군구): {sample}  
            - 참고: Cluster는 K-means로 유형화한 값이며, traffic_infra는 전체면적 대비 대중교통 비중을 의미한다.  

            [요청]  
            1. 각 행정구역(region)에 대해 금융취약성 정도를 0~100 사이 정수(score)로 평가하라.  
            2. 점수 산정 근거(reason)를 간략히 요약하라.  
            3. 반드시 아래 JSON 스키마를 따를 것.  

            [출력 형식]  
            {format_instructions}
            - 출력은 반드시 순수 JSON만 포함해야 한다.
            - 주석(//, # 등) 금지
            - 불필요한 설명 문장 금지
            - 잘린 객체 없이 완전한 JSON으로 출력
            - 모든 객체는 region, features, score 세 필드를 반드시 가져야 함
            """
        ).partial(
            columns=list(df.columns),
            sample=batch.to_dict(orient="records"),
            format_instructions=parser.get_format_instructions(),
        )

        chain = prompt | model | parser

        try:
            batch_result: AnalyzeResults = await chain.ainvoke({})
            print(f"✅ 배치 {i//batch_size+1} 처리 완료 ({len(batch_result.results)}개)")
            results.extend(batch_result.results)
        except Exception as e:
            print(f"❌ 배치 {i//batch_size+1} 처리 실패:", e)

    # DataFrame 변환
    df_result = pd.DataFrame([r.dict() for r in results])
    print(f"총 {len(df_result)}개 행정구역 결과 반환")
    return df_result


# ------------------------
# 단계 2: MCP 보조 호출 (DeepResearch + Kakao Navigation with Distance)
# ------------------------


# MCP 서버 설정 로드
async def load_servers_config(file_path: str = "src/report_server.json") -> dict:
    path = Path(file_path)
    if not path.exists():
        return {}

    with path.open("r", encoding="utf-8") as f:
        return json.load(f).get("mcpServers", {})
    
async def enrich_with_mcp(candidates: list, base_location: str = "서울역"):
    """
    candidates: List[dict] (예: [{"region": "...", "score": 85, "reason": "..."}])
    """
    servers = await load_servers_config()
    if not servers:
        return candidates

    client = MultiServerMCPClient(servers)
    tools = await client.get_tools()

    deep_tool = next((t for t in tools if t.name == "DeepResearchMCP"), None)
    nav_tool = next((t for t in tools if t.name == "kakao-navigation-mcp-server"), None)

    enriched = []

    for cand in candidates:
        region = cand.get("region")

        # DeepResearchMCP 호출
        if deep_tool:
            deep_res = await client.run_tool(
                "DeepResearchMCP",
                {"query": f"{region} 지역의 금융 취약성 및 사회경제적 특징"}
            ) or {}
            cand["deep_research"] = deep_res.get("output", "N/A")

        # Kakao Navigation MCP 호출 → 거리/시간 포함
        if nav_tool:
            nav_res = await client.run_tool(
                "kakao-navigation-mcp-server",
                {"origin": base_location, "destination": region}
            ) or {}
            cand["navigation_info"] = nav_res.get("output", "N/A")

        enriched.append(cand)

    print(enriched)
    return enriched



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
        - 전략제안 부분은 표 형태로 제시할 것
        """
    ).partial(
        enriched=enriched_data,
        seq=seq_result or "순차적 사고 결과 없음"
    )

    response = await (prompt | model).ainvoke({})
    return response.content

# ------------------------
# 전체 파이프라인 실행
# ------------------------
async def full_pipeline():
    # 1단계: 데이터 분석
    candidates_df = await analyze_data(cluster_data, batch_size=50)
    candidates = candidates_df.to_dict(orient="records")

    # 2단계: MCP 보강
    enriched = await enrich_with_mcp(candidates)

    # 3단계: Sequential Thinking + 보고서 생성
    report = await generate_report(json.dumps(enriched, ensure_ascii=False))

    return report
