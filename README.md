# Unstructured Transform extension for Gemini CLI

This repository is the [Gemini CLI](https://github.com/google-gemini/gemini-cli)
extension for the [Unstructured Transform](https://transform.unstructured.io)
MCP server (`https://mcp.transform.unstructured.io`). It lets Gemini CLI
parse documents (PDF, DOCX, PPTX, XLSX, HTML, EML, images, and multiple
other formats) into markdown, element JSON, HTML, or plain text.

The [Transform documentation](https://docs.unstructured.io/transform/overview)
is the source of truth for what the server does, its
[supported file types](https://docs.unstructured.io/transform/supported-file-types),
[parsing options](https://docs.unstructured.io/transform/output), request
limits, and billing. This repository only carries the Gemini extension
manifest and the agent guidance the extension ships.

## Install

```sh
gemini extensions install https://github.com/Unstructured-IO/transform-gemini-extension
```

The first time the `transform` server starts, a browser window opens for
a one-time Unstructured sign-in (OAuth; no API key needed). The token is
cached, so you only sign in once. The extension ships the agent guidance
in [`AGENTS.md`](AGENTS.md).

The server is launched through [`mcp-remote`](https://www.npmjs.com/package/mcp-remote),
so you need Node.js 18+ with `npx` on your PATH. `mcp-remote` is fetched
on first use. It handles the OAuth flow that Gemini CLI's native remote
transport does not yet complete reliably; see
[CONTRIBUTING.md](CONTRIBUTING.md#transport) for the detail.

Using another tool (Claude Code, Claude Desktop, Cursor, Codex, Google
Antigravity, Cline)? See the
[official install guides](https://docs.unstructured.io/transform/install/overview)
and the [Unstructured MCP integrations](https://github.com/Unstructured-IO/unstructured-mcp-integrations)
index.

## Using it

Ask Gemini to parse something, for example: *"Parse report.pdf to
markdown."* The agent uploads the file, starts a job, polls until it
finishes, and writes the structured result. Large or scanned files can
take a few minutes. [`AGENTS.md`](AGENTS.md) carries the guidance agents
follow for this flow.

## Repository structure

```text
├── AGENTS.md                  # agent guidance, shipped with the extension
├── gemini-extension.json      # Gemini CLI extension manifest
├── scripts/validate.sh        # consistency checks (plain bash)
├── .github/workflows/
│   └── validate.yml           # runs the checks in CI
├── CODEOWNERS
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── .editorconfig
├── .gitattributes
└── .gitignore
```

## Validation

```sh
./scripts/validate.sh
```

Checks that the manifest is valid JSON and that no tracked file
references a server URL other than the one in the manifest. Runs in CI on
pull requests and pushes to `main`.

## Contributing

This repository is maintained by the Unstructured team. Bug reports and
suggestions are welcome as issues. See [CONTRIBUTING.md](CONTRIBUTING.md)
before opening a pull request.

## Learn more

- [Transform overview](https://docs.unstructured.io/transform/overview)
- [Transform quickstart](https://docs.unstructured.io/transform/quickstart)
- [Install guides for other tools](https://docs.unstructured.io/transform/install/overview)
- [Unstructured Transform](https://transform.unstructured.io)

## License

[MIT](LICENSE)
