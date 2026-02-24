#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSV="${1:-"$SCRIPT_DIR/urls.csv"}"

if [[ ! -f "$CSV" ]]; then
    echo "Error: '$CSV' not found." >&2
    exit 1
fi

# Skip the header row; parse url and path columns
tail -n +2 "$CSV" | while IFS=, read -r url path rest; do
    [[ -z "$url" ]] && continue
    "$SCRIPT_DIR/fetch-page.sh" "$url" "$path"
done
