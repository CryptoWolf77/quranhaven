"""Read-only provider metadata and bounded MP3 sample checks (no audio mirroring)."""

from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
from urllib.request import Request, urlopen


def sample(url):
    request = Request(url, headers={
        "User-Agent": "QuranHaven-Audio-Check/1.0",
        "Range": "bytes=0-4095",
        "Origin": "https://quranhaven.org",
    })
    with urlopen(request, timeout=25) as response:
        # Some providers ignore Range. Never read the entire recording.
        data = response.read(4096)
        if response.status not in (200, 206):
            raise ValueError(f"HTTP {response.status}: {url}")
        if not response.url.startswith("https://"):
            raise ValueError(f"Insecure redirect: {url}")
        content_type = response.headers.get_content_type()
        if content_type not in ("audio/mpeg", "audio/mp3", "application/octet-stream"):
            raise ValueError(f"Unexpected content type {content_type}: {url}")
        if len(data) < 128 or not (data.startswith(b"ID3") or
                                  (data[0] == 255 and data[1] & 224 == 224)):
            raise ValueError(f"Not an MP3 prefix: {url}")
        return f"PASS {response.status} {url} (CORS={response.headers.get('Access-Control-Allow-Origin', 'absent')})"


def main():
    entries = json.loads(Path(__file__).with_name("reciters.json").read_text(encoding="utf-8"))
    with urlopen("https://www.mp3quran.net/api/v3/reciters?language=eng", timeout=30) as response:
        catalogue = json.load(response)["reciters"]
    urls = []
    for entry in entries:
        reciter = next(r for r in catalogue if r["id"] == entry["reciter_id"])
        edition = next(m for m in reciter["moshaf"] if m["id"] == entry["moshaf_id"])
        if (edition["server"] != entry["surah_root"] or
                edition["rewaya_id"] != 1 or edition["surah_total"] != 114 or
                {int(n) for n in edition["surah_list"].split(",")} != set(range(1, 115))):
            raise ValueError(f"Hafs/114-Surah source mismatch: {entry['name']}")
        print(f"CATALOGUE PASS {entry['name']} (ID {entry['reciter_id']}, Hafs, 114 Surahs)", flush=True)
        urls.extend(entry["surah_root"] + name + ".mp3" for name in ("001", "002", "114"))
        urls.extend("https://everyayah.com/data/" + entry["ayah_folder"] + "/" + name + ".mp3"
                    for name in ("001001", "002255", "114006"))
    with ThreadPoolExecutor(max_workers=4) as pool:
        for result in pool.map(sample, urls):
            print(result, flush=True)
    print(f"Verified {len(entries)} catalogues and {len(urls)} bounded MP3 samples. Not a full recording audit.")


if __name__ == "__main__":
    main()
