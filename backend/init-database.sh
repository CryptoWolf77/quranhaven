#!/bin/sh
set -eu
# Runs only for a new, empty PostgreSQL volume. Never log either password.
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  --set=ON_ERROR_STOP=1 --set=app_password="$QURAN_APP_PASSWORD" <<'SQL'
CREATE ROLE quran LOGIN PASSWORD :'app_password' NOSUPERUSER NOCREATEDB NOCREATEROLE;
ALTER DATABASE quran OWNER TO quran;
REVOKE ALL ON DATABASE quran FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
ALTER SCHEMA public OWNER TO quran;
SQL
