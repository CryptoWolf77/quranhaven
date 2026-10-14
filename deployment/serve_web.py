"""Serve a built Flutter app locally with deterministic MIME types on Windows."""

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import re


class WebHandler(SimpleHTTPRequestHandler):
    # Reuse well-framed connections during the hundreds of shell downloads.
    # Every static/ranged response supplies its exact Content-Length.
    protocol_version = "HTTP/1.1"
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
        ".mp4": "video/mp4",
    }

    def send_head(self):
        # Test fresh responses; do not let the browser HTTP cache conceal worker
        # failures or preserve a MIME type from a different local server.
        if "If-Modified-Since" in self.headers:
            del self.headers["If-Modified-Since"]
        self._quran_remaining = None
        path = Path(self.translate_path(self.path)).resolve()
        root = Path(self.directory).resolve()
        if path.suffix.lower() == ".mp4" and path.is_file() and root in path.parents:
            size = path.stat().st_size
            start, end = 0, size - 1
            ranged = self.headers.get("Range")
            # One bounded byte range only, matching the app's offline worker.
            # If-Range is not supported by this no-store development server.
            if self.headers.get("If-Range"):
                ranged = None
            if ranged:
                match = re.fullmatch(r"bytes=(\d*)-(\d*)", ranged)
                invalid = not match or not any(match.groups())
                if not invalid:
                    try:
                        left, right = match.groups()
                        if left:
                            start = int(left)
                            end = int(right) if right else size - 1
                        else:
                            suffix = int(right)
                            start = max(0, size - suffix)
                            invalid = suffix <= 0
                        invalid = invalid or start < 0 or start >= size or end < start
                    except ValueError:
                        invalid = True
                if invalid:
                    self.send_response(416)
                    self.send_header("Content-Range", f"bytes */{size}")
                    self.send_header("Content-Length", "0")
                    self.end_headers()
                    return None
                end = min(end, size - 1)
            source = path.open("rb")
            source.seek(start)
            self._quran_remaining = end - start + 1
            self.send_response(206 if ranged else 200)
            self.send_header("Content-type", "video/mp4")
            self.send_header("Accept-Ranges", "bytes")
            self.send_header("Content-Length", str(self._quran_remaining))
            if ranged:
                self.send_header("Content-Range", f"bytes {start}-{end}/{size}")
            self.end_headers()
            return source
        return super().send_head()

    def copyfile(self, source, outputfile):
        if self._quran_remaining is None:
            return super().copyfile(source, outputfile)
        remaining = self._quran_remaining
        while remaining:
            chunk = source.read(min(64 * 1024, remaining))
            if not chunk:
                break
            outputfile.write(chunk)
            remaining -= len(chunk)

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
