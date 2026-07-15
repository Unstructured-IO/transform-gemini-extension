#!/usr/bin/env bash
# Validate that the extension files stay consistent: the manifest is
# valid JSON, and every file references the same server URL as
# gemini-extension.json.
set -euo pipefail

cd "$(dirname "$0")/.."
fail=0

err() {
    echo "FAIL: $1" >&2
    fail=1
}

# The extension manifest must exist and be valid JSON.
if [ ! -f gemini-extension.json ]; then
    err "gemini-extension.json is missing"
elif command -v jq >/dev/null 2>&1; then
    jq empty gemini-extension.json 2>/dev/null \
        || err "gemini-extension.json is not valid JSON"
elif command -v python3 >/dev/null 2>&1 && python3 -c '' 2>/dev/null; then
    python3 -m json.tool gemini-extension.json >/dev/null 2>&1 \
        || err "gemini-extension.json is not valid JSON"
else
    echo "SKIP: no JSON validator found for gemini-extension.json (install jq)" >&2
fi

# Every file must reference the same server URL as the manifest, and no
# file may carry a different mcp.* server URL (partial drift).
if command -v jq >/dev/null 2>&1; then
    canonical=$(jq -r '.mcpServers.transform.httpUrl // empty' gemini-extension.json 2>/dev/null || true)
else
    canonical=$(grep -oE '"httpUrl"[[:space:]]*:[[:space:]]*"https://[^"]+"' gemini-extension.json \
        | grep -oE 'https://[^"]+' | head -1 || true)
fi
if [ -n "$canonical" ]; then
    for f in AGENTS.md README.md; do
        if [ ! -f "$f" ]; then
            err "$f is missing"
        elif ! grep -q "$canonical" "$f"; then
            err "$f does not reference the canonical server URL ($canonical)"
        elif grep -oE 'https://mcp\.[A-Za-z0-9./-]*[A-Za-z0-9/-]' "$f" \
                | grep -vqx "$canonical"; then
            err "$f contains a server URL that differs from the canonical one ($canonical)"
        fi
    done
else
    err "could not extract the canonical server URL from gemini-extension.json"
fi

if [ "$fail" -eq 0 ]; then
    echo "OK: extension files are consistent"
fi
exit "$fail"
