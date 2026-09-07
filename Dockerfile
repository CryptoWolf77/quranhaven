# Flutter version and checksum are from the official Linux release manifest.
# Build on an x86_64/amd64 server; the final image contains no Flutter SDK.
FROM debian:bookworm-slim AS web-build
ARG FLUTTER_VERSION=3.44.7
ARG FLUTTER_SHA256=a0edd646c159c0e816788c0e46a4f071199c1320495898f5a679599b583a05a4
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*
RUN test "$(dpkg --print-architecture)" = amd64 \
    && curl --fail --show-error --location --retry 3 \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      --output /tmp/flutter.tar.xz \
    && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum --check - \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter config --no-analytics --enable-web && flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock l10n.yaml analysis_options.yaml .metadata ./
COPY vendor/ ./vendor/
COPY lib/ ./lib/
COPY web/ ./web/
# pub get also generates localizations, so ARB files must already be present.
RUN flutter pub get --enforce-lockfile
ARG QURAN_CONTENT_URL=https://quranhaven.org/v1/
ARG QURAN_API_URL=https://api.quranhaven.org
RUN flutter build web --release --no-pub --no-web-resources-cdn \
      --dart-define=QURAN_CONTENT_URL=${QURAN_CONTENT_URL} \
      --dart-define=QURAN_API_URL=${QURAN_API_URL}

FROM python:3.13-alpine AS verified-content
WORKDIR /content
COPY content/prepare_content.py ./
COPY content/public/ ./public/
RUN python prepare_content.py --root /content --verify --public-only

FROM nginxinc/nginx-unprivileged:stable-alpine
COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=web-build /app/build/web/ /usr/share/nginx/html/
COPY --from=verified-content /content/public/ /usr/share/nginx/html/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
