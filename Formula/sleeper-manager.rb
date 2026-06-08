class SleeperManager < Formula
  desc "AI commissioner for Sleeper fantasy football leagues (local backend)"
  homepage "https://sleeper.darthworks.io"
  url "https://sleeper.darthworks.io/downloads/sleeper-manager-source.tar.gz"
  version "1.9.24"
  sha256 "64ba3a5ea3a769c926ddc3c29398a1b878bb361e270b0f7c9a1bc603ff2780fa"
  license "MIT"

  depends_on "python@3.13"

  # Cross-platform install path (the macOS cask ships the .app; this Formula is the
  # CLI for Linux + Mac CLI users). It stages the source read-only in the Cellar; the
  # `sleeper-manager start` wrapper syncs it to a writable ~/.sleeper-manager/app on
  # first run (the app writes its SQLite + caches into data/ in-tree, so it can't run
  # straight from the read-only Cellar), builds a venv there, fetches the MCP binary,
  # and launches uvicorn on :8000.
  def install
    libexec.install Dir["*"]

    (bin/"sleeper-manager").write <<~EOS
      #!/bin/bash
      set -uo pipefail

      LIBEXEC="#{libexec}"
      PY="#{Formula["python@3.13"].opt_bin}/python3.13"
      VERSION="#{version}"
      BASE="$HOME/.sleeper-manager"
      APP="$BASE/app"
      MCP_BIN="$BASE/sleeper-mcp"
      MCP_URL="https://artifacts.darthworks.io/sleeper/sleeper-mcp"

      usage() {
        cat <<USAGE
      sleeper-manager — local backend for the Sleeper Manager web app

      Usage:
        sleeper-manager start    Start the local backend at http://localhost:8000
        sleeper-manager help     Show this help

      The web app lives at https://sleeper.darthworks.io — in Settings pick the
      "Claude Max (local)" provider to route chat to this backend. All data lives
      under ~/.sleeper-manager (nothing is written into the Homebrew Cellar).
      USAGE
      }

      case "${1:-help}" in
        start)
          mkdir -p "$BASE"

          # Sync the source into a writable working copy; re-sync on version change.
          if [ "$(cat "$APP/.version" 2>/dev/null)" != "$VERSION" ]; then
            echo "→ Installing Sleeper Manager $VERSION into $APP …"
            rm -rf "$APP"
            mkdir -p "$APP"
            cp -R "$LIBEXEC/." "$APP/"
            rm -rf "$APP/.venv"   # rebuild the venv for the new version
            echo "$VERSION" > "$APP/.version"
          fi

          # Python venv (first run only).
          if [ ! -x "$APP/.venv/bin/uvicorn" ]; then
            echo "→ Setting up the Python environment (first run, ~1-2 min) …"
            "$PY" -m venv "$APP/.venv" || { echo "✗ Could not create the venv with $PY"; exit 1; }
            "$APP/.venv/bin/python" -m pip install --quiet --upgrade pip
            "$APP/.venv/bin/python" -m pip install --quiet -r "$APP/backend/requirements.txt" \\
              || { echo "✗ Dependency install failed."; exit 1; }
          fi

          # MCP binary (~95 MB). Versions independently of this release, so it is
          # fetched at runtime rather than baked into the content-addressed Formula.
          if [ ! -x "$MCP_BIN" ]; then
            echo "→ Downloading the MCP binary (~95 MB, first run) …"
            curl -fL# "$MCP_URL" -o "$MCP_BIN" || { echo "✗ MCP download failed."; exit 1; }
            chmod +x "$MCP_BIN"
          fi
          export SLEEPER_MCP_PATH="$MCP_BIN"

          if ! command -v claude >/dev/null 2>&1; then
            echo "⚠ Claude Code CLI not found on PATH — chat needs it: https://docs.claude.com/claude-code"
          fi

          echo "✓ Starting backend at http://localhost:8000  (leave this open; Ctrl+C to stop)"
          cd "$APP" || exit 1
          exec "$APP/.venv/bin/uvicorn" backend.main:app --port 8000
          ;;
        help|-h|--help)
          usage
          ;;
        *)
          echo "Unknown command: $1"
          echo
          usage
          exit 1
          ;;
      esac
    EOS

    chmod 0755, bin/"sleeper-manager"
  end

  def caveats
    <<~EOS
      Start the local backend with:
        sleeper-manager start

      First run downloads the MCP binary (~95 MB) and builds a Python venv under
      ~/.sleeper-manager. Chat also requires the Claude Code CLI on your PATH:
        https://docs.claude.com/claude-code

      The web UI is hosted at https://sleeper.darthworks.io — set the provider to
      "Claude Max (local)" in Settings to use this backend.
    EOS
  end

  test do
    assert_match "sleeper-manager start", shell_output("#{bin}/sleeper-manager help")
  end
end
