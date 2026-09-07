import os


# Tests must never connect to the deployment database or use its signing key.
os.environ["ENVIRONMENT"] = "test"
os.environ["DATABASE_URL"] = "sqlite:///:memory:"
os.environ["SECRET_KEY"] = "test-secret-key-that-is-longer-than-thirty-two-characters"
os.environ["CORS_ORIGINS"] = "http://localhost:8080"
