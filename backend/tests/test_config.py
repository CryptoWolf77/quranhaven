import pytest
from pydantic import ValidationError

from app.config import DEVELOPMENT_SECRET, Settings
from app.schemas import SyncWrite


def production_settings(**overrides) -> Settings:
    return Settings(_env_file=None, **{
        "environment": "production",
        "database_url": "postgresql+psycopg://quran:private-database-password@database:5432/quran",
        "secret_key": "0123456789abcdef" * 4,
        "cors_origins": "https://quranhaven.org,https://www.quranhaven.org",
        **overrides,
    })


def test_valid_production_settings_and_normalized_environment():
    settings = production_settings(environment=" Production ")
    assert settings.environment == "production"
    assert settings.allowed_origins == ["https://quranhaven.org", "https://www.quranhaven.org"]


@pytest.mark.parametrize("secret", [
    DEVELOPMENT_SECRET,
    "short",
    "a" * 64,
    "replace-with-at-least-64-random-characters-for-your-project-secret-key",
    "test-secret-key-that-is-longer-than-forty-eight-characters",
    "0123456789abcdef" * 3 + " ",
])
def test_production_rejects_default_placeholder_or_weak_secrets(secret):
    with pytest.raises(ValidationError):
        production_settings(secret_key=secret)


@pytest.mark.parametrize("database_url", [
    "sqlite:///:memory:",
    "postgresql://quran:password@database:5432/quran",
    "postgresql+psycopg://quran@database:5432/quran",
    "postgresql+psycopg://quran:password@database:5432",
    "not-a-database-url",
])
def test_production_requires_explicit_postgresql_configuration(database_url):
    with pytest.raises(ValidationError):
        production_settings(database_url=database_url)


@pytest.mark.parametrize("origin", [
    "", "*", "http://quranhaven.org", "https://*.quranhaven.org",
    "https://quranhaven.org/", "https://quranhaven.org/reader",
    "https://quranhaven.org?x=1", "https://quranhaven.org#reader",
    "https://user:password@quranhaven.org", "https://", "https://quranhaven.org:bad",
    "https://quran haven.org", "https://quranhaven.org:0",
])
def test_production_requires_exact_https_cors_origins(origin):
    with pytest.raises(ValidationError):
        production_settings(cors_origins=origin)


@pytest.mark.parametrize("minutes", [0, -1, 43_201])
def test_token_lifetime_is_bounded(minutes):
    with pytest.raises(ValidationError):
        production_settings(access_token_minutes=minutes)


def test_invalid_environment_does_not_silently_disable_production_validation():
    with pytest.raises(ValidationError):
        production_settings(environment="prod")


def test_validation_errors_hide_sensitive_configuration_values():
    private_secret = "0123456789abcdef" * 4
    private_url = "postgresql+psycopg://quran:private-password@database:5432/quran"
    with pytest.raises(ValidationError) as error:
        production_settings(secret_key=private_secret, database_url=private_url, cors_origins="*")
    assert private_secret not in str(error.value)
    assert private_url not in str(error.value)


@pytest.mark.parametrize("value", [float("nan"), float("inf"), float("-inf")])
def test_backup_rejects_non_finite_json_numbers(value):
    with pytest.raises(ValidationError):
        SyncWrite(data={"value": value})
