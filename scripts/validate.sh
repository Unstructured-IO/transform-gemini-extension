#!/usr/bin/env bash
# Validate that the extension files stay consistent: the manifest is
# valid JSON, and no tracked file references a server URL other than the
# canonical one in gemini-extension.json.
set -euo pipefail

cd "$(dirname "$0")/.."
fail=0

err() {
    echo "FAIL: $1" >&2
    fail=1
}

have_python() {
    command -v python3 >/dev/null 2>&1 && python3 -c '' 2>/dev/null
}

# The extension manifest must exist and be valid JSON.
if [ ! -f gemini-extension.json ]; then
    err "gemini-extension.json is missing"
elif command -v jq >/dev/null 2>&1; then
    jq empty gemini-extension.json 2>/dev/null \
        || err "gemini-extension.json is not valid JSON"
elif have_python; then
    python3 -m json.tool gemini-extension.json >/dev/null 2>&1 \
        || err "gemini-extension.json is not valid JSON"
else
    echo "SKIP: no JSON validator found for gemini-extension.json (install jq)" >&2
fi

# Extract the canonical server URL from the manifest. Parse the JSON
# where a parser is available; only fall back to text scanning when
# neither jq nor python3 is present.
if command -v jq >/dev/null 2>&1; then
    canonical=$(jq -r '.mcpServers.transform.httpUrl // empty' gemini-extension.json 2>/dev/null || true)
elif have_python; then
    canonical=$(python3 -c 'import json; print(json.load(open("gemini-extension.json")).get("mcpServers", {}).get("transform", {}).get("httpUrl", ""))' 2>/dev/null || true)
else
    canonical=$(grep -oE '"httpUrl"[[:space:]]*:[[:space:]]*"https://[^"]+"' gemini-extension.json \
        | grep -oE 'https://[^"]+' | head -1 || true)
fi

if [ -z "$canonical" ]; then
    err "could not extract the canonical server URL from gemini-extension.json"
else
    # The docs that carry the URL must reference the canonical one, matched
    # as a fixed string so the dots are not treated as regex wildcards.
    for f in AGENTS.md README.md; do
        if [ ! -f "$f" ]; then
            err "$f is missing"
        elif ! grep -Fq "$canonical" "$f"; then
            err "$f does not reference the canonical server URL ($canonical)"
        fi
    done

    # No tracked file may reference a different transform server URL.
    # Derive the file list from git so files added later are covered
    # automatically; skip this script, which names the URL pattern.
    while IFS= read -r f; do
        [ "$f" = "scripts/validate.sh" ] && continue
        [ -f "$f" ] || continue
        if grep -oE 'https://mcp\.[A-Za-z0-9./-]*[A-Za-z0-9/-]' "$f" 2>/dev/null \
                | grep -Fvqx "$canonical"; then
            err "$f references a server URL that differs from the canonical one ($canonical)"
        fi
    done < <(git ls-files)
fi

if [ "$fail" -eq 0 ]; then
    echo "OK: extension files are consistent"
fi
exit "$fail"
