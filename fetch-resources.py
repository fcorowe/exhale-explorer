"""Cache public boundaries and Leaflet for the local HASP explorer."""

import hashlib
import io
import json
import time
import urllib.parse
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / "resources"
CACHE.mkdir(exist_ok=True)
MANIFEST = CACHE / "sources.json"
sources = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}


def fetch(url):
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "EXHALE-local-preview/1.0"})
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)


def record(path, urls):
    sources[path.name] = {
        "urls": urls,
        "retrieved_utc": datetime.now(timezone.utc).isoformat(),
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "bytes": path.stat().st_size,
    }
    MANIFEST.write_text(json.dumps(sources, indent=2) + "\n")


def arcgis(filename, service, fields, count, order_field):
    path = CACHE / filename
    if path.exists() and filename in sources:
        print("Cached:", filename, flush=True)
        return
    features, urls = [], []
    for offset in range(0, count, 1000):
        query = urllib.parse.urlencode({
            "where": "1=1", "outFields": fields, "f": "geojson",
            "outSR": 4326, "geometryPrecision": 8,
            "resultOffset": offset, "resultRecordCount": 1000,
            "orderByFields": order_field,
        })
        url = service + "/query?" + query
        page = json.loads(fetch(url))
        if "error" in page:
            raise RuntimeError(page["error"])
        features.extend(page["features"])
        urls.append(url)
        print(filename, len(features), "/", count, flush=True)
    if len(features) != count:
        raise ValueError(f"{filename}: expected {count} boundaries, found {len(features)}")
    if any(not feature.get("geometry") for feature in features):
        raise ValueError(f"{filename}: missing geometry")
    path.write_text(json.dumps({"type": "FeatureCollection", "features": features}))
    record(path, urls)


arcgis(
    "ew-msoa-2021-full.geojson",
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"
    "Middle_layer_Super_Output_Areas_December_2021_Boundaries_EW_BGC_V3/FeatureServer/0",
    "MSOA21CD,MSOA21NM", 7264, "FID",
)
arcgis(
    "scotland-iz-2022-full.geojson",
    "https://services-eu1.arcgis.com/4QkhM5AS8YOlkb6T/ArcGIS/rest/services/"
    "2022_Data_Zones_and_Intermediate_Zones/FeatureServer/1",
    "IZCode,IZName", 1334, "OBJECTID",
)

ni_path = CACHE / "ni-sdz-2021.geojson"
if not ni_path.exists() or ni_path.name not in sources:
    ni_url = "https://www.nisra.gov.uk/files/nisra/publications/geography-sdz2021-geojson.zip"
    with zipfile.ZipFile(io.BytesIO(fetch(ni_url))) as archive:
        members = [p for p in archive.namelist() if p.lower().endswith((".geojson", ".json"))]
        if len(members) != 1:
            raise ValueError(f"Unexpected NISRA archive contents: {members}")
        contents = archive.read(members[0])
    if len(json.loads(contents)["features"]) != 850:
        raise ValueError("Expected 850 Northern Ireland Super Data Zones")
    ni_path.write_bytes(contents)
    record(ni_path, [ni_url])
    print("Downloaded:", ni_path.name, flush=True)

for dataset in ["ne_10m_lakes", "ne_10m_lakes_europe"]:
    archive_path = CACHE / (dataset + ".zip")
    url = "https://naturalearth.s3.amazonaws.com/10m_physical/" + dataset + ".zip"
    if not archive_path.exists() or archive_path.name not in sources:
        archive_path.write_bytes(fetch(url))
        record(archive_path, [url])
    with zipfile.ZipFile(archive_path) as archive:
        for member in archive.namelist():
            filename = Path(member).name
            if Path(filename).suffix.lower() not in {".shp", ".shx", ".dbf", ".prj", ".cpg"}:
                continue
            path = CACHE / filename
            if not path.exists() or filename not in sources:
                path.write_bytes(archive.read(member))
                record(path, [url])
    print("Cached lake dataset:", dataset, flush=True)

for filename in ["leaflet.js", "leaflet.css", "LICENSE"]:
    path = CACHE / ("leaflet-license.txt" if filename == "LICENSE" else filename)
    if not path.exists() or path.name not in sources:
        url = "https://unpkg.com/leaflet@1.9.4/" + (filename if filename == "LICENSE" else "dist/" + filename)
        path.write_bytes(fetch(url))
        record(path, [url])
        print("Downloaded:", path.name, flush=True)

# Embed display assets and font licences in the shared HTML.
asset_urls = {
    "figtree.woff2": "https://cdn.jsdelivr.net/fontsource/fonts/figtree:vf@latest/latin-wght-normal.woff2",
    "space-grotesk.woff2": "https://cdn.jsdelivr.net/fontsource/fonts/space-grotesk:vf@latest/latin-wght-normal.woff2",
    "figtree-license.txt": "https://cdn.jsdelivr.net/npm/@fontsource-variable/figtree@latest/LICENSE",
    "space-grotesk-license.txt": "https://cdn.jsdelivr.net/npm/@fontsource-variable/space-grotesk@latest/LICENSE",
}
for image in ["layers.png", "layers-2x.png", "marker-icon.png", "marker-icon-2x.png", "marker-shadow.png"]:
    asset_urls[image] = "https://unpkg.com/leaflet@1.9.4/dist/images/" + image
for filename, url in asset_urls.items():
    path = CACHE / filename
    if not path.exists() or filename not in sources:
        contents = fetch(url)
        if filename.endswith(".woff2") and contents[:4] != b"wOF2":
            raise ValueError("Invalid WOFF2 font: " + filename)
        if filename.endswith(".png") and contents[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError("Invalid PNG image: " + filename)
        path.write_bytes(contents)
        record(path, [url])
        print("Downloaded:", filename, flush=True)
