# YoniMoore-It/homebrew-tap

Custom Homebrew tap for Sleeper Manager and related tooling.

Sleeper Manager ships two install paths from this tap:

| Path | Platform | What you get |
|------|----------|--------------|
| **Formula** | Linux + macOS (CLI) | A `sleeper-manager` command that runs the local backend |
| **Cask** | macOS only | The `Sleeper Manager.app` (double-click to launch) |

## Linux (and macOS CLI) — Formula

```bash
brew tap YoniMoore-It/tap
brew install yonimoore-it/tap/sleeper-manager   # resolves to the formula
sleeper-manager start
```

Casks are macOS-only, so on Linux this is the path to use. `brew install` defaults
to the formula and prints a note that a cask also exists — that's expected. (On a
Mac, add `--formula` to force the CLI, or use the cask below for the app.)

`sleeper-manager start`:
1. Syncs the source into a writable working copy under `~/.sleeper-manager/app`
   (re-synced on version change — the Cellar copy is read-only).
2. Builds a Python venv and installs the backend dependencies (first run only).
3. Downloads the MCP binary (~95 MB, first run).
4. Launches the backend at <http://localhost:8000>.

Then open <https://sleeper.darthworks.io> and pick the **"Claude Max (local)"**
provider in Settings to route chat to your backend. All state lives under
`~/.sleeper-manager` — nothing is written into the Homebrew Cellar.

## macOS app — Cask

```bash
brew install --cask YoniMoore-It/tap/sleeper-manager
```

This downloads `Sleeper Manager.app`, strips macOS quarantine attributes (no
Gatekeeper warning), and installs to `/Applications`. Double-click the app to start
the local backend (it opens Terminal and runs the installer + uvicorn).

## Requirements

- **Formula:** Linux or macOS, [Homebrew](https://brew.sh)
- **Cask:** macOS 10.13+
- [Claude Code CLI](https://docs.claude.com/claude-code) on your `PATH` (chat shells
  out to `claude`)

## Uninstall

```bash
# Formula
brew uninstall sleeper-manager
rm -rf ~/.sleeper-manager          # optional: remove data + venv + MCP binary

# Cask
brew uninstall --cask sleeper-manager

brew untap YoniMoore-It/tap        # optional
```
