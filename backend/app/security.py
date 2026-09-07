from datetime import UTC, datetime, timedelta
from uuid import UUID

import jwt
from pwdlib import PasswordHash

from .config import get_settings


password_hash = PasswordHash.recommended()
settings = get_settings()


def hash_password(password: str) -> str:
    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    return password_hash.verify(password, hashed_password)


def create_access_token(user_id: str) -> str:
    now = datetime.now(UTC)
    expires = now + timedelta(minutes=settings.access_token_minutes)
    return jwt.encode(
        {"sub": user_id, "iat": now, "exp": expires},
        settings.secret_key,
        algorithm="HS256",
    )


def decode_access_token(token: str) -> str | None:
    try:
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=["HS256"],
            options={"require": ["sub", "iat", "exp"]},
        )
    except jwt.PyJWTError:
        return None
    subject = payload.get("sub")
    issued_at, expires_at = payload.get("iat"), payload.get("exp")
    if (
        not isinstance(subject, str)
        or type(issued_at) is not int
        or type(expires_at) is not int
        or expires_at <= issued_at
    ):
        return None
    try:
        if str(UUID(subject)) != subject:
            return None
    except ValueError:
        return None
    return subject
