from datetime import datetime
import json
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    display_name: str = Field(min_length=2, max_length=80)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("display_name", mode="before")
    @classmethod
    def clean_display_name(cls, value: Any) -> Any:
        return " ".join(value.split()) if isinstance(value, str) else value


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: EmailStr
    display_name: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead


class SyncWrite(BaseModel):
    data: dict[str, Any]

    @field_validator("data")
    @classmethod
    def limit_backup_size(cls, value: dict[str, Any]) -> dict[str, Any]:
        try:
            size = len(json.dumps(value, separators=(",", ":"), allow_nan=False).encode("utf-8"))
        except (ValueError, TypeError, RecursionError) as error:
            raise ValueError("Cloud backup must contain valid JSON data") from error
        if size > 1_000_000:
            raise ValueError("Cloud backup cannot exceed 1 MB")
        return value


class SyncRead(BaseModel):
    data: dict[str, Any] | None
    revision: int
    updated_at: datetime | None


class HealthRead(BaseModel):
    status: str
    service: str
