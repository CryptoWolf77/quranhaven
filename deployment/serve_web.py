"""Serve a built Flutter app locally with deterministic MIME types on Windows."""

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class WebHandler(SimpleHTTPRequestHandler):
    # Windows registry associations can otherwise label JS as text/plain,
    # which browsers correctly reject for CanvasKit dynamic module imports.
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".js": "application/javascript",
        ".mjs": "application/javascript",
        ".wasm": "application/wasm",
        ".json": "application/json",
        ".bin": "application/octet-stream",
        ".gz": "application/gzip",
    }

    def send_head(self):
        # Test fresh responses; do not let the browser HTTP cache conceal worker
        # failures or preserve a MIME type from a different local server.
        if "If-Modified-Since" in self.headers:
            del self.headers["If-Modified-Since"]
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--web-root", type=Path, required=True)
    parser.add_argument("--port", type=int, default=8086)
    args = parser.parse_args()
    root = args.web_root.resolve(strict=True)
    if not (root / "index.html").is_file() or not (1 <= args.port <= 65535):
        parser.error("Provide a built Flutter web directory and a valid port")
    handler = partial(WebHandler, directory=str(root))
    with ThreadingHTTPServer(("127.0.0.1", args.port), handler) as server:
        print(f"Local Quran Haven check: http://127.0.0.1:{args.port}", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()
