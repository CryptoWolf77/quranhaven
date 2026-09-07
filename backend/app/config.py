from functools import lru_cache
from typing import Self
from urllib.parse import urlsplit

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import make_url
from sqlalchemy.exc import ArgumentError


DEVELOPMENT_SECRET = "development-only-change-before-deployment"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        hide_input_in_errors=True,
    )

    app_name: str = "Quran Flutter Cloud"
    environment: str = "development"
    database_url: str = "sqlite:///./quran_cloud.db"
    secret_key: str = DEVELOPMENT_SECRET
    access_token_minutes: int = Field(default=60 * 24 * 30, ge=1, le=60 * 24 * 30)
    cors_origins: str = "http://localhost:8080,http://127.0.0.1:8080"

    @field_validator("secret_key")
    @classmethod
    def validate_secret_key(cls, value: str) -> str:
        if len(value) < 32:
            raise ValueError("SECRET_KEY must contain at least 32 characters")
        return value

    @field_validator("environment", mode="before")
    @classmethod
    def normalize_environment(cls, value: str) -> str:
        value = value.strip().lower()
        if value not in {"development", "test", "production"}:
            raise ValueError("ENVIRONMENT must be development, test, or production")
        return value

    @model_validator(mode="after")
    def validate_production_configuration(self) -> Self:
        if self.environment != "production":
            return self

        secret = self.secret_key
        if (
            len(secret) < 48
            or len(set(secret)) < 12
            or any(character.isspace() for character in secret)
            or secret == DEVELOPMENT_SECRET
            or any(
                placeholder in secret.lower()
                for placeholder in ("change-before", "change-me", "changeme", "replace-with", "test-secret")
            )
        ):
            raise ValueError("Production SECRET_KEY must be a private random secret of at least 48 characters")

        try:
            database = make_url(self.database_url)
        except ArgumentError as error:
            raise ValueError("Production DATABASE_URL must be a valid PostgreSQL connection URL") from error
        if (
            database.drivername != "postgresql+psycopg"
            or not database.host
            or not database.database
            or not database.username
            or not database.password
        ):
            raise ValueError("Production DATABASE_URL must use postgresql+psycopg with host, database, username, and password")

        origins = self.allowed_origins
        if not origins:
            raise ValueError("Production CORS_ORIGINS must explicitly list the HTTPS web-app origins")
        for origin in origins:
            try:
                parsed = urlsplit(origin)
                port = parsed.port
            except ValueError as error:
                raise ValueError("Production CORS_ORIGINS contains an invalid origin") from error
            if (
                parsed.scheme != "https"
                or not parsed.hostname
                or parsed.username is not None
                or parsed.password is not None
                or parsed.path
                or parsed.query
                or parsed.fragment
                or "*" in origin
                or any(character.isspace() for character in origin)
                or (port is not None and port == 0)
            ):
                raise ValueError("Production CORS_ORIGINS must contain exact HTTPS origins without paths or wildcards")
        return self

    @property
    def allowed_origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
