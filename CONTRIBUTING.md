# Contributing

This repository is maintained by the [Unstructured](https://unstructured.io)
team. Bug reports and suggestions are welcome as GitHub issues; pull
requests are reviewed by Unstructured maintainers.

## Ground rules

- The [Transform documentation](https://docs.unstructured.io/transform/overview)
  is the primary source. This repository carries only what the Gemini CLI
  extension needs; do not restate docs content here.
- Keep this repository dependency-free: no package managers, runtimes, or
  frameworks. Validation stays plain bash.
- The server URL appears in `gemini-extension.json`, `AGENTS.md`, and
  `README.md`; `scripts/validate.sh` enforces that they all match the
  manifest. If the endpoint ever changes, change it everywhere in one
  pull request.
- Run `./scripts/validate.sh` before opening a pull request.

## Transport

The manifest launches the server through `npx -y mcp-remote <url>` rather
than pointing Gemini CLI's native `httpUrl` remote transport at the
server directly. The Transform server authenticates with OAuth via
Dynamic Client Registration, and Gemini CLI's native remote-OAuth path
does not attach the acquired token on the request that follows sign-in
for DCR / auto-discovered servers, so the connection fails to establish
([google-gemini/gemini-cli#27745](https://github.com/google-gemini/gemini-cli/issues/27745)).
`mcp-remote` performs the OAuth flow correctly and caches the token, so
sign-in is a one-time browser step. The cost is a Node.js 18+ / `npx`
runtime requirement for users.

When the upstream bug is fixed and released, this can move back to the
simpler native transport:

```json
"transform": { "httpUrl": "https://mcp.transform.unstructured.io" }
```

That change also needs `scripts/validate.sh` reverted to read the URL
from `.mcpServers.transform.httpUrl` and the README install steps updated
back to `/mcp auth transform`.

## Shipping updates

This extension is installed from its GitHub URL
(`gemini extensions install https://github.com/Unstructured-IO/transform-gemini-extension`).
For that install method Gemini CLI checks for updates with `git ls-remote`,
comparing the latest commit on the default branch against the installed
`HEAD`, so merging to `main` is what prompts installed users to update.
The `version` field in `gemini-extension.json` does not drive updates for
GitHub-URL installs; still bump it alongside a meaningful change so the
manifest reflects what shipped.

## Reporting problems

Open an issue with the tool name, its version, and what it read (or failed
to read). Tool conventions change between releases, so version
information matters.
