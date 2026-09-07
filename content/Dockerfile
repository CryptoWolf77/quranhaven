FROM python:3.13-alpine AS verified
WORKDIR /content
COPY prepare_content.py .
COPY public/ ./public/
RUN python prepare_content.py --root /content --verify --public-only

FROM nginxinc/nginx-unprivileged:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=verified /content/public/ /usr/share/nginx/html/

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/v1/manifest.json || exit 1
