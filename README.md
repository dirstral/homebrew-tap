# homebrew-tap

Homebrew tap for [dir2mcp](https://github.com/Dirstral/dir2mcp) — index any local directory and serve it as a private MCP knowledge server.

## Install

```sh
brew tap Dirstral/tap
```

Install the MCP server (lean binary):

```sh
brew install dir2mcp
```

Install the full runtime with bundled Docling dependencies:

```sh
brew install dir2mcp-full
```

Install the interactive TUI client:

```sh
brew install dirstral
```

## Upgrade

```sh
brew upgrade dir2mcp
brew upgrade dirstral
```

## Formulas

| Formula | Description |
|---------|-------------|
| `dir2mcp` | Index any local directory and serve it as a private MCP knowledge server with RAG, citations, and optional x402 payment gating. |
| `dir2mcp-full` | Full runtime variant of `dir2mcp` that bundles an isolated Python Docling environment for document ingestion. |
| `dirstral` | Interactive TUI client for dir2mcp knowledge bases. |

## Source

Releases are built and published automatically by [GoReleaser](https://goreleaser.com) from the [dir2mcp](https://github.com/Dirstral/dir2mcp) repository on every version tag.
