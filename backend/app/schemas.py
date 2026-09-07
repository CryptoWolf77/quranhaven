from datetime import datetime
import json
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    display_name: str = Field(min_length=2, max_length=80)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("display_name")
    @classmethod
    def clean_display_name(cls, value: str) -> str:
        return " ".join(value.split())


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
        size = len(json.dumps(value, separators=(",", ":")).encode("utf-8"))
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
