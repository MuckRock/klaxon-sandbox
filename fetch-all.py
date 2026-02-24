#!/usr/bin/env python3
"""Fetch all pages listed in urls.csv and record the main HTML file for each."""

import csv
import os
import subprocess
import sys
from urllib.parse import urlparse

script_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(script_dir, "urls.csv")
fetch_page = os.path.join(script_dir, "fetch-page.sh")


def find_main_html(outdir, url):
    """Return the path (relative to outdir) of the main HTML file wget saved."""
    url_path = urlparse(url).path
    if url_path.endswith("/") or not url_path:
        # Trailing-slash URL: wget saves index.html inside the path directory.
        rel = url_path.strip("/")
        candidates = [os.path.join(rel, "index.html") if rel else "index.html"]
    else:
        # No trailing slash: wget names the file after the last path component,
        # possibly with .html appended by --adjust-extension.
        rel = url_path.lstrip("/")
        candidates = [rel + ".html", rel]

    for candidate in candidates:
        if os.path.isfile(os.path.join(outdir, candidate)):
            return candidate
    return None


with open(csv_path, newline="") as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    rows = list(reader)

for row in rows:
    url  = row["url"].strip()
    path = row["path"].strip()
    if not url or not path:
        continue

    subprocess.run([fetch_page, url, path], check=True)

    index = find_main_html(path, url)
    if index:
        row["index"] = index
    else:
        print(f"Warning: could not locate main HTML file in {path}/", file=sys.stderr)

    # Persist after each download so progress is saved if a later one fails
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
