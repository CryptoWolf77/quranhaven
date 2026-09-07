# Quran Flutter cloud service

This optional service stores a user's voluntary Quran progress backup. The app
continues to work without it.

## Local development

```sh
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt
.venv/Scripts/pytest
.venv/Scripts/uvicorn app.main:app --reload
```

The default development database is SQLite. Set `DATABASE_URL` to use
PostgreSQL.

## Coolify deployment

Deploy `backend/compose.yaml`, create long random values for
`POSTGRES_PASSWORD` and `SECRET_KEY`, and set `CORS_ORIGINS` to the exact HTTPS
web-app origin. Keep PostgreSQL private; only expose the API through HTTPS.

Build the Flutter app with the deployed service:

```sh
flutter build apk --release \
  --dart-define=QURAN_API_URL=https://api.example.org
```

## API

- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `GET /v1/sync`
- `PUT /v1/sync`
- `GET /health`

Passwords are Argon2-hashed. The API returns expiring JWT access tokens; the
Flutter app keeps them in encrypted platform storage.
