#!/usr/bin/env python3
"""Generate an index.html listing all pages from urls.csv."""

import csv
import html
import os
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(script_dir, "urls.csv")
output_path = (
    sys.argv[2] if len(sys.argv) > 2 else os.path.join(script_dir, "index.html")
)

pages = []
with open(csv_path, newline="") as f:
    for row in csv.DictReader(f):
        url = row["url"].strip()
        path = row["path"].strip()
        index = row.get("index", "").strip()
        if url and path:
            href = f"{path}/{index}" if index else f"{path}/"
            pages.append((url, href))

items = "\n".join(
    f'      <li><a href="{html.escape(href)}">{html.escape(url)}</a></li>'
    for url, href in pages
)

content = f"""\
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Klaxon sandbox</title>
  <style>
    body {{ font-family: sans-serif; max-width: 48rem; margin: 2rem auto; padding: 0 1rem; }}
    h1   {{ font-size: 1.5rem; margin-bottom: 0.5rem; }}
    li   {{ line-height: 2; }}
  </style>
</head>
<body>
  <h1>Klaxon sandbox</h1>
  <p>Saved page snapshots for testing the Klaxon extension.</p>
  <ul>
{items}
  </ul>
</body>
</html>
"""

with open(output_path, "w") as f:
    f.write(content)

print(f"Written: {output_path}")
