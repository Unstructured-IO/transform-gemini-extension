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
