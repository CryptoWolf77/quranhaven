from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

from fastapi import FastAPI, HTTPException, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from .config import get_settings
from .database import Base, engine
from .dependencies import Database
from .routes import account, auth, sync
from .schemas import HealthRead


settings = get_settings()


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    docs_url="/docs" if settings.environment != "production" else None,
    openapi_url="/openapi.json" if settings.environment != "production" else None,
    redoc_url=None,
    lifespan=lifespan,
)


@app.exception_handler(RequestValidationError)
async def invalid_request(_, error: RequestValidationError) -> JSONResponse:
    # Never echo submitted passwords or private backup contents in an error.
    # Omitting inputs also keeps invalid non-finite JSON values serializable.
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        content={
            "detail": [
                {"type": item["type"], "loc": item["loc"], "msg": item["msg"]}
                for item in error.errors()
            ]
        },
    )


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)
app.include_router(auth.router)
app.include_router(sync.router)
app.include_router(account.router)


@app.get("/health", response_model=HealthRead)
def health(db: Database) -> HealthRead:
    try:
        db.execute(text("SELECT 1"))
    except SQLAlchemyError as error:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable",
        ) from error
    return HealthRead(status="ok", service=settings.app_name)
