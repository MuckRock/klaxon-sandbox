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
    echo "Error: '$OUTDIR' already exists." >&2
    exit 1
fi

# Clean up the output directory if wget fails
trap 'echo "Failed — removing partial output."; rm -rf "$OUTDIR"' ERR

mkdir -p "$OUTDIR"

echo "Fetching:  $URL"
echo "Output:    $OUTDIR/"
echo ""

# --no-directories flattens all assets into one level, so relative links in the
# converted HTML are plain filenames — safe to rename the main file afterward.
wget \
    --page-requisites \
    --convert-links \
    --span-hosts \
    --no-directories \
    --directory-prefix="$OUTDIR" \
    --adjust-extension \
    "$URL"

trap - ERR

# Derive the filename wget used for the main page.
# Strip query/fragment, then take the last path component.
MAIN_NAME=$(printf '%s' "$URL" | sed 's|[?#].*||' | sed 's|.*\/||')

# A root URL (e.g. https://example.com/) produces an empty name → index.html
[[ -z "$MAIN_NAME" ]] && MAIN_NAME="index.html"

# --adjust-extension may have appended .html to an extension-less name
if [[ "$MAIN_NAME" != *.html && "$MAIN_NAME" != *.htm ]]; then
    [[ -f "$OUTDIR/${MAIN_NAME}.html" ]] && MAIN_NAME="${MAIN_NAME}.html"
fi

# Rename to index.html if not already named that
if [[ "$MAIN_NAME" != "index.html" && -f "$OUTDIR/$MAIN_NAME" ]]; then
    mv "$OUTDIR/$MAIN_NAME" "$OUTDIR/index.html"
fi

echo ""
echo "Saved to:  $OUTDIR/"
echo "Main page: $OUTDIR/index.html"
