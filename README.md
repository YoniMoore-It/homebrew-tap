# YoniMoore-It/homebrew-tap

Custom Homebrew tap for Sleeper Manager and related tooling.

## Install

```bash
brew tap YoniMoore-It/tap
brew install --cask sleeper-manager
```

Or one-shot:

```bash
brew install --cask YoniMoore-It/tap/sleeper-manager
```

This will:
1. Download `Sleeper Manager.app` from sleeper.darthworks.io
2. Strip macOS quarantine attributes (no Gatekeeper warning)
3. Install to `/Applications/Sleeper Manager.app`

After install, double-click the app to start the local backend. The app opens Terminal and runs the installer + uvicorn.

## Requirements

- macOS 10.13+
- [Claude Code CLI](https://docs.claude.com/claude-code) (the backend shells out to `claude`)
- Git

## Uninstall

```bash
brew uninstall --cask sleeper-manager
brew untap YoniMoore-It/tap   # optional
```

Add `--zap` to also remove `~/sleeper-manager` and caches.
