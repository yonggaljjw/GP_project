from typing import Annotated
import os

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBasicCredentials, HTTPBasic
from fastapi.openapi.docs import get_swagger_ui_html, get_redoc_html
from fastapi.openapi.utils import get_openapi
from fastapi.middleware.cors import CORSMiddleware

from src.router import router as chat_router


app = FastAPI(docs_url=None,
              redoc_url=None,
              openapi_url=None)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],    # 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router, prefix="/api")

## 보안처리

SWAGGER_USERNAME = os.getenv("SWAGGER_USER", "admin")
SWAGGER_PASSWORD = os.getenv("SWAGGER_PASS", "secret") 

security = HTTPBasic()
 
def authenticate_user(credentials: Annotated[HTTPBasicCredentials, Depends(security)]):
    if (
        credentials.username != SWAGGER_USERNAME
        or credentials.password != SWAGGER_PASSWORD
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect Credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
 
@app.get("/docs", include_in_schema=False)
async def get_docs(
    credentials: Annotated[HTTPBasicCredentials, Depends(authenticate_user)],
):
    return get_swagger_ui_html(openapi_url="/openapi.json", title="Swagger UI")
 
@app.get("/redoc", include_in_schema=False)
async def get_redocs(
    credentials: Annotated[HTTPBasicCredentials, Depends(authenticate_user)],
):
    return get_redoc_html(openapi_url="/openapi.json", title="ReDoc")
 
@app.get("/openapi.json", include_in_schema=False)
async def get_open_api_endpoint(
    credentials: Annotated[HTTPBasicCredentials, Depends(authenticate_user)],
):
    return get_openapi(
        title="FastAPI with Private Swagger",
        version="0.1.0",
        routes=app.routes,
    )
 