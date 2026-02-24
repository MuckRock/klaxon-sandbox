#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename "$0") <url> [directory]" >&2
    exit 1
fi

URL="$1"

if [[ -n "${2:-}" ]]; then
    OUTDIR="$2"
else
    # Derive a filesystem-friendly name from the URL
    OUTDIR=$(printf '%s' "$URL" \
        | sed 's|^https\?://||' \
        | sed 's|/$||' \
        | tr '/?=&#:@' '-' \
        | tr -s '-' \
        | sed 's/^-//;s/-$//')
fi

if [[ -e "$OUTDIR" ]]; then
    echo "'$OUTDIR' already exists." >&2
    exit 0
fi

# Clean up the output directory if wget fails
trap 'echo "Failed — removing partial output."; rm -rf "$OUTDIR"' ERR

mkdir -p "$OUTDIR"

echo "Fetching:  $URL"
echo "Output:    $OUTDIR/"
echo ""

wget \
    --page-requisites \
    --convert-links \
    --span-hosts \
    --no-host-directories \
    --no-parent \
    --directory-prefix="$OUTDIR" \
    --adjust-extension \
    --tries=3 \
    --waitretry=2 \
    --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    "$URL" || {
    rc=$?
    # Exit code 8 means a server returned an error for one or more assets
    # (404s, rate limits, etc.). The main page is still usable, so continue.
    [[ $rc -eq 8 ]] || exit $rc
    echo "Warning: some assets could not be fetched (wget exit 8)"
}

trap - ERR

echo ""
echo "Saved to: $OUTDIR/"
