"""Deterministic checks for the loopback-only Flutter development server."""

import contextlib
from functools import partial
import http.client
import importlib.util
import io
from pathlib import Path
import tempfile
import threading
import unittest
from unittest import mock


SPEC = importlib.util.spec_from_file_location(
    "serve_web", Path(__file__).with_name("serve_web.py")
)
web = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(web)


class WebServerTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.content = b"public test asset\x00\xff"
        for name in ("index.html", "main.js", "module.mjs", "module.JS",
                     "renderer.wasm", "offline-index.bin", "manifest.json", "text.gz"):
            (self.root / name).write_bytes(self.content)
        logging = mock.patch.object(web.WebHandler, "log_message")
        logging.start()
        self.addCleanup(logging.stop)
        self.server = web.ThreadingHTTPServer(
            ("127.0.0.1", 0), partial(web.WebHandler, directory=str(self.root))
        )
        self.thread = threading.Thread(
            target=self.server.serve_forever,
            kwargs={"poll_interval": 0.01},
            daemon=True,
        )
        self.thread.start()
        self.addCleanup(self.stop_server)

    def stop_server(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)

    def request(self, path, method="GET", headers=None):
        connection = http.client.HTTPConnection(
            "127.0.0.1", self.server.server_port, timeout=2
        )
        try:
            connection.request(method, path, headers=headers or {})
            response = connection.getresponse()
            return response.status, dict(response.getheaders()), response.read()
        finally:
            connection.close()

    def test_static_mime_types_and_no_store(self):
        for name, mime in (
            ("main.js", "application/javascript"),
            ("module.mjs", "application/javascript"),
            ("module.JS", "application/javascript"),
            ("renderer.wasm", "application/wasm"),
            ("offline-index.bin", "application/octet-stream"),
            ("manifest.json", "application/json"),
            ("text.gz", "application/gzip"),
        ):
            with self.subTest(name=name):
                status, headers, body = self.request("/" + name)
                self.assertEqual(status, 200)
                self.assertEqual(headers["Content-type"], mime)
                self.assertEqual(headers["Cache-Control"], "no-store")
                self.assertEqual(body, self.content)

    def test_conditional_request_returns_fresh_body_instead_of_304(self):
        status, headers, body = self.request(
            "/main.js",
            headers={"If-Modified-Since": "Fri, 31 Dec 9999 23:59:59 GMT"},
        )
        self.assertEqual(status, 200)
        self.assertEqual(headers["Cache-Control"], "no-store")
        self.assertEqual(body, self.content)

    def test_missing_file_is_not_cached_or_replaced_with_index(self):
        status, headers, body = self.request("/missing.js")
        self.assertEqual(status, 404)
        self.assertEqual(headers["Cache-Control"], "no-store")
        self.assertNotEqual(body, self.content)

    def test_head_preserves_mime_and_no_store_without_body(self):
        status, headers, body = self.request("/renderer.wasm", method="HEAD")
        self.assertEqual(status, 200)
        self.assertEqual(headers["Content-type"], "application/wasm")
        self.assertEqual(headers["Content-Length"], str(len(self.content)))
        self.assertEqual(headers["Cache-Control"], "no-store")
        self.assertEqual(body, b"")

    def test_main_binds_only_loopback_and_serves_requested_root(self):
        with mock.patch.object(web, "ThreadingHTTPServer") as factory, \
                mock.patch("sys.argv", ["serve_web.py", "--web-root", str(self.root)]), \
                contextlib.redirect_stdout(io.StringIO()):
            web.main()
        address, handler = factory.call_args.args
        self.assertEqual(address, ("127.0.0.1", 8086))
        self.assertIs(handler.func, web.WebHandler)
        self.assertEqual(handler.keywords, {"directory": str(self.root.resolve())})
        factory.return_value.__enter__.return_value.serve_forever.assert_called_once_with()

    def test_main_rejects_invalid_ports_without_opening_a_server(self):
        for port in ("0", "65536"):
            with self.subTest(port=port), \
                    mock.patch.object(web, "ThreadingHTTPServer") as factory, \
                    mock.patch("sys.argv", ["serve_web.py", "--web-root", str(self.root),
                                             "--port", port]), \
                    contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as stopped:
                    web.main()
                self.assertEqual(stopped.exception.code, 2)
                factory.assert_not_called()


if __name__ == "__main__":
    unittest.main()
