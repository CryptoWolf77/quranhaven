import os
from uuid import uuid4

os.environ["DATABASE_URL"] = "sqlite:///:memory:"
os.environ["SECRET_KEY"] = "test-secret-key-that-is-longer-than-thirty-two-characters"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


def test_registration_login_and_sync_round_trip() -> None:
    email = f"reader-{uuid4()}@example.com"
    credentials = {
        "display_name": "Quran Reader",
        "email": email,
        "password": "a-secure-test-password",
    }

    with TestClient(app) as client:
        registration = client.post("/v1/auth/register", json=credentials)
        assert registration.status_code == 201
        token = registration.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        empty_backup = client.get("/v1/sync", headers=headers)
        assert empty_backup.status_code == 200
        assert empty_backup.json()["data"] is None

        snapshot = {
            "schema_version": 1,
            "last_read_page": 42,
            "plans": {"khatmah": None, "memorization": []},
        }
        saved = client.put("/v1/sync", headers=headers, json={"data": snapshot})
        assert saved.status_code == 200
        assert saved.json()["revision"] == 1

        restored = client.get("/v1/sync", headers=headers)
        assert restored.status_code == 200
        assert restored.json()["data"] == snapshot

        login = client.post(
            "/v1/auth/login",
            json={"email": email, "password": credentials["password"]},
        )
        assert login.status_code == 200
        assert login.json()["user"]["email"] == email


def test_duplicate_email_is_rejected() -> None:
    email = f"duplicate-{uuid4()}@example.com"
    payload = {
        "display_name": "Reader",
        "email": email,
        "password": "a-secure-test-password",
    }
    with TestClient(app) as client:
        assert client.post("/v1/auth/register", json=payload).status_code == 201
        assert client.post("/v1/auth/register", json=payload).status_code == 409
