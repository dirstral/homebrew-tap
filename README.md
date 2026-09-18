# homebrew-tap

Homebrew tap for [dir2mcp](https://github.com/Dirstral/dir2mcp) — index any local directory and serve it as a private MCP knowledge server.

## Install

```sh
brew tap Dirstral/tap
brew trust dirstral/tap
```

The `brew trust` step is required. Homebrew 6 and later refuse to load formulae
from an untrusted third-party tap, and `brew install dirstral/tap/dir2mcp` reads
the sibling `dir2mcp-full` formula while resolving, so **the lean install fails
too** without it (#42). Older Homebrew has no `trust` subcommand and needs
nothing here.

Install the MCP server (lean binary):

```sh
brew install dir2mcp
```

Install the full runtime with bundled Docling dependencies:

```sh
brew install dir2mcp-full
```

### Choosing a track

`dir2mcp` and `dir2mcp-full` both provide the `dir2mcp` command, so they conflict
and cannot be linked at the same time. Installing one over the other fails until
the first is unlinked (#43):

```sh
brew unlink dir2mcp && brew install dir2mcp-full   # lean  -> full
brew unlink dir2mcp-full && brew install dir2mcp   # full  -> lean
```

`brew unlink` keeps the other version on disk, so switching back is fast. Use
`brew uninstall` instead if you want the space returned.

**The full track is large** (#45). Measured on the released 0.10.0:

| Platform | Installed size | Files | Install time |
| --- | --- | --- | --- |
| macOS 26 arm64 | 1.1 GB | 38,718 | ~4m30s |
| Linux x86_64 | 6.3 GB | 39,137 | ~3m20s |

Both numbers are the same tree; Linux carries much larger native wheels. The
bulk is an isolated Python 3.12 environment with docling, torch, torchvision,
scipy and shapely. Choose the lean track unless you need document extraction.

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
