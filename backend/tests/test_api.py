from datetime import UTC, datetime, timedelta
from unittest.mock import Mock
from uuid import uuid4

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.exc import OperationalError

from app.config import get_settings
from app.database import SessionLocal, get_db
from app.main import app
from app.models import User, UserSync


@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client


def register_reader(client: TestClient, **overrides) -> dict:
    payload = {
        "display_name": "Quran Reader",
        "email": f"reader-{uuid4()}@example.com",
        "password": "a-secure-test-password",
        **overrides,
    }
    registration = client.post("/v1/auth/register", json=payload)
    assert registration.status_code == 201, registration.text
    return registration.json()


def session_headers(registration: dict) -> dict[str, str]:
    return {"Authorization": f"Bearer {registration['access_token']}"}


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


@pytest.mark.parametrize("display_name", [" ", " \t\n  ", "  A \t"])
def test_display_name_length_is_checked_after_normalization(client, display_name):
    response = client.post(
        "/v1/auth/register",
        json={
            "display_name": display_name,
            "email": f"reader-{uuid4()}@example.com",
            "password": "a-secure-test-password",
        },
    )
    assert response.status_code == 422


def test_display_name_collapses_whitespace_and_email_is_normalized(client):
    email = f"READER-{uuid4()}@EXAMPLE.COM"
    registration = register_reader(client, display_name="  Quran\t  Reader \n", email=email)
    assert registration["user"]["display_name"] == "Quran Reader"
    assert registration["user"]["email"] == email.lower()
    assert client.post(
        "/v1/auth/login", json={"email": email, "password": "a-secure-test-password"}
    ).status_code == 200


@pytest.mark.parametrize(
    ("method", "path", "body"),
    [("GET", "/v1/sync", None), ("PUT", "/v1/sync", {"data": {}}), ("DELETE", "/v1/account", None)],
)
def test_private_endpoints_require_authentication(client, method, path, body):
    response = client.request(method, path, json=body)
    assert response.status_code == 401
    assert response.headers["www-authenticate"] == "Bearer"


@pytest.mark.parametrize(
    "claims",
    [
        {},
        {"iat": 1},
        {"iat": 1, "exp": 2},
        {"iat": "not-a-time", "exp": 4_000_000_000},
        {"iat": 4_000_000_000, "exp": 4_000_000_001},
        {"iat": 1, "exp": "4000000000"},
        {"iat": True, "exp": 4_000_000_000},
        {"iat": 1, "exp": 4_000_000_000, "sub": ""},
        {"iat": 1, "exp": 4_000_000_000, "sub": "not-a-user-id"},
    ],
)
def test_invalid_or_missing_token_claims_are_rejected(client, claims):
    registration = register_reader(client)
    token = jwt.encode(
        {"sub": registration["user"]["id"], **claims},
        get_settings().secret_key,
        algorithm="HS256",
    )
    response = client.get("/v1/sync", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401


def test_expired_bad_signature_and_missing_subject_tokens_are_rejected(client):
    now = datetime.now(UTC)
    registration = register_reader(client)
    claims = {"sub": registration["user"]["id"], "iat": now, "exp": now + timedelta(hours=1)}
    tokens = [
        "malformed-token",
        jwt.encode(claims, "incorrect-secret-that-is-not-the-configured-secret", algorithm="HS256"),
        jwt.encode({"iat": now, "exp": now + timedelta(hours=1)}, get_settings().secret_key, algorithm="HS256"),
        jwt.encode({**claims, "iat": now - timedelta(hours=2), "exp": now - timedelta(hours=1)}, get_settings().secret_key, algorithm="HS256"),
    ]
    for token in tokens:
        assert client.get("/v1/sync", headers={"Authorization": f"Bearer {token}"}).status_code == 401


def test_wrong_password_and_unknown_email_are_rejected(client):
    registration = register_reader(client)
    for email in [registration["user"]["email"], f"missing-{uuid4()}@example.com"]:
        response = client.post("/v1/auth/login", json={"email": email, "password": "wrong-password"})
        assert response.status_code == 401
        assert response.json()["detail"] == "Invalid email or password"


def test_backups_remain_separate_for_each_user(client):
    first, second = register_reader(client), register_reader(client)
    first_data = {"last_read_page": 42, "user_id": second["user"]["id"]}
    assert client.put("/v1/sync", headers=session_headers(first), json={"data": first_data}).status_code == 200
    assert client.get("/v1/sync", headers=session_headers(second)).json() == {
        "data": None, "revision": 0, "updated_at": None
    }
    assert client.put("/v1/sync", headers=session_headers(second), json={"data": {"last_read_page": 100}}).status_code == 200
    assert client.get("/v1/sync", headers=session_headers(first)).json()["data"] == first_data
    assert client.get("/v1/sync", headers=session_headers(second)).json()["data"] == {"last_read_page": 100}


def test_account_deletion_removes_backup_and_revokes_all_issued_tokens(client):
    first, second = register_reader(client), register_reader(client)
    first_headers, second_headers = session_headers(first), session_headers(second)
    login = client.post("/v1/auth/login", json={"email": first["user"]["email"], "password": "a-secure-test-password"})
    login_headers = session_headers(login.json())
    now = datetime.now(UTC)
    earlier_session = jwt.encode(
        {"sub": first["user"]["id"], "iat": now - timedelta(minutes=10), "exp": now + timedelta(hours=1)},
        get_settings().secret_key,
        algorithm="HS256",
    )
    earlier_headers = {"Authorization": f"Bearer {earlier_session}"}
    assert earlier_session != first["access_token"]
    assert client.get("/v1/sync", headers=earlier_headers).status_code == 200
    for headers in [first_headers, second_headers]:
        assert client.put("/v1/sync", headers=headers, json={"data": {"last_read_page": 42}}).status_code == 200
    response = client.delete("/v1/account", headers=first_headers)
    assert response.status_code == 204
    assert response.content == b""
    with SessionLocal() as db:
        assert db.get(User, first["user"]["id"]) is None
        assert db.get(UserSync, first["user"]["id"]) is None
        assert db.get(User, second["user"]["id"]) is not None
        assert db.get(UserSync, second["user"]["id"]) is not None
    for headers in [first_headers, login_headers, earlier_headers]:
        assert client.get("/v1/sync", headers=headers).status_code == 401
        assert client.put("/v1/sync", headers=headers, json={"data": {}}).status_code == 401
        assert client.delete("/v1/account", headers=headers).status_code == 401
    assert client.post("/v1/auth/login", json={"email": first["user"]["email"], "password": "a-secure-test-password"}).status_code == 401
    assert client.get("/v1/sync", headers=second_headers).status_code == 200
    new_account = register_reader(client, email=first["user"]["email"])
    assert new_account["user"]["id"] != first["user"]["id"]
    assert client.get("/v1/sync", headers=session_headers(new_account)).json()["data"] is None
    assert client.get("/v1/sync", headers=first_headers).status_code == 401


def test_backup_limit_and_rejected_backup_does_not_overwrite_existing_data(client):
    headers = session_headers(register_reader(client))
    # {"x":""} is eight bytes in the API's compact UTF-8 JSON representation.
    boundary = {"x": "a" * 999_992}
    accepted = client.put("/v1/sync", headers=headers, json={"data": boundary})
    assert accepted.status_code == 200
    rejected = client.put("/v1/sync", headers=headers, json={"data": {"x": "a" * 999_993}})
    assert rejected.status_code == 422
    stored = client.get("/v1/sync", headers=headers).json()
    assert stored["data"] == boundary
    assert stored["revision"] == 1
    updated = client.put("/v1/sync", headers=headers, json={"data": {"last_read_page": 2}})
    assert updated.json()["revision"] == 2


@pytest.mark.parametrize("data", [None, [], "not-a-backup"])
def test_backup_must_be_an_object(client, data):
    headers = session_headers(register_reader(client))
    assert client.put("/v1/sync", headers=headers, json={"data": data}).status_code == 422


def test_invalid_json_and_private_inputs_are_not_echoed_in_validation_errors(client):
    headers = session_headers(register_reader(client))
    response = client.put(
        "/v1/sync", headers={**headers, "Content-Type": "application/json"},
        content='{"data":{"private_note":"private-note-never-echo", "value":NaN}}',
    )
    assert response.status_code == 422
    assert "private-note-never-echo" not in response.text
    invalid_registration = client.post("/v1/auth/register", json={
        "display_name": "Reader", "email": "invalid-email", "password": "secret",
    })
    assert invalid_registration.status_code == 422
    assert "secret" not in invalid_registration.text
    assert all("input" not in error for error in invalid_registration.json()["detail"])


def test_database_readiness_and_failure_does_not_expose_connection_details(client):
    assert client.get("/health").status_code == 200
    assert client.get("/health").json()["status"] == "ok"
    failed_db = Mock()
    failed_db.execute.side_effect = OperationalError("SELECT 1", {}, Exception("private connection detail"))
    app.dependency_overrides[get_db] = lambda: failed_db
    try:
        response = client.get("/health")
        assert response.status_code == 503
        assert response.json() == {"detail": "Database unavailable"}
        assert "private connection detail" not in response.text
    finally:
        app.dependency_overrides.clear()


def test_account_deletion_is_allowed_in_cors_preflight(client):
    response = client.options("/v1/account", headers={
        "Origin": "http://localhost:8080",
        "Access-Control-Request-Method": "DELETE",
        "Access-Control-Request-Headers": "authorization",
    })
    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "http://localhost:8080"
