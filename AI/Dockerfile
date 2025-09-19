FROM python:3.12-slim

# ✅ nodejs, npm 설치
RUN apt-get update && apt-get install -y nodejs npm

# ✅ uv 설치
RUN pip install uv

WORKDIR /app

# ✅ 파일 복사
COPY . .

# ✅ 의존성 설치
RUN uv sync

EXPOSE 8000

# FastAPI 앱 실행 예시 (필요에 따라 수정)
CMD ["uv", "run", "python", "-m", "src.fastapi_app"]