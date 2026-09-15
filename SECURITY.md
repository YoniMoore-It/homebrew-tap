# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the `security-hardening` skill). Findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** Public Homebrew tap — distributes `sleeper-manager` CLI + Cask · **Prod:** GitHub-hosted tap · **Stack:** Homebrew Ruby (Formula + Cask)

**Last audit:** 2026-09-15 · **Scope of run:** own asset, read-only / non-destructive static analysis.

---

## Open Findings

| ID | Sev | Category | Location (file:line) | Finding | Fix | Status |
|----|-----|----------|----------------------|---------|-----|--------|
| HB-01 | Med | Supply Chain | `Formula/sleeper-manager.rb:72-74` | The install script downloads a ~95 MB MCP binary at runtime from `https://artifacts.darthworks.io/sleeper/sleeper-mcp` via `curl -fL#` and immediately `chmod +x`s it, with **no checksum or signature verification**. Homebrew's SHA256 covers only the source tarball; this secondary binary download is outside Homebrew's content-addressed model. A DNS hijack, CDN compromise, or server-side swap would silently install and execute a malicious binary on the user's machine. | (1) Add `MCP_SHA256='<expected-hash>'` constant to the formula. (2) After download: `echo "$MCP_SHA256  $MCP_BIN" \| sha256sum -c \|\| { rm -f "$MCP_BIN"; odie 'MCP binary checksum mismatch'; }`. (3) Long-term: bake the binary into the content-addressed tarball so Homebrew verifies it automatically. | open |

---

## Confirmed Secure

- 2026-09-15 — All download URLs use HTTPS. ✓
- 2026-09-15 — Formula SHA256 (64-char hex) is present and valid for the source tarball. ✓
- 2026-09-15 — Cask SHA256 (64-char hex) is present and valid for the `.zip` bundle. ✓
- 2026-09-15 — `uvicorn` bound to port 8000 with no `--host` flag — defaults to localhost only; no external network exposure. ✓
- 2026-09-15 — No hardcoded credentials anywhere in the formula or cask. ✓
- 2026-09-15 — Install script does not interpolate any user-controlled input into shell commands. ✓
- 2026-09-15 — `test do` block verifies help output — basic sanity check in place. ✓

---

## Untested / Needs Setup

- Runtime behavior of the installed `sleeper-mcp` binary (pre-compiled; audited separately in `sleeper-manager` and `sleeper-api-mcp` repos).
- Supply-chain trust for `artifacts.darthworks.io` CDN relies on owner-controlled infrastructure.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
| — | — | — | — |
