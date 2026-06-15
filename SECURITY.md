# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the `security-hardening` skill). Same discipline as BUGREPORT.md: findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** public Homebrew tap (Formula + Cask for sleeper-manager) · **Prod:** https://github.com/yonimoore-it/homebrew-tap · **Stack:** Ruby Homebrew DSL only

**Last audit:** 2026-06-15 · **Scope of run:** own asset, read-only / non-destructive static audit.

---

## Open Findings

| ID | Sev | Category | Location (file:line or URL) | Finding | Fix | Status |
|----|-----|----------|------------------------------|---------|-----|--------|
| SEC-1 | Critical | Input/deps | `Formula/sleeper-manager.rb:69-74` | MCP binary (`~95 MB`) downloaded at runtime from `https://artifacts.darthworks.io/sleeper/sleeper-mcp` with **no sha256 check, no version pin in the URL, no signature**. Binary is immediately `chmod +x`'d and executed. A compromised origin or CDN swap is undetectable post-download. | Embed the expected sha256 in the Formula and verify with `shasum -a 256` before `chmod +x`, or bundle the binary inside the content-addressed source tarball | open |
| SEC-2 | High | Input/deps | `Formula/sleeper-manager.rb:64-66` | `pip install -r requirements.txt` resolves live PyPI at first run. If `requirements.txt` lacks `--hash=sha256:...` entries, a dependency can be silently substituted. | Pass `--require-hashes` and ship a `pip-compile --generate-hashes` lockfile; enforce at the Formula layer with `pip install --require-hashes -r requirements.txt` | open |
| SEC-3 | Medium | Public-exposure | Repo root | No `.gitignore`. Editor swap files, `.DS_Store`, or an accidentally staged `.env` are one `git add .` away from a commit. | Add `.gitignore` covering `*.DS_Store`, `*.swp`, `.env*` | open |
| SEC-4 | Low | Public-exposure | `Casks/sleeper-manager.rb:12-15` | `zap trash:` lists `~/sleeper-manager` (no dot-prefix) but the Formula writes runtime data to `~/.sleeper-manager`. If the macOS app uses the same dot-prefix path, uninstall via `--zap` silently leaves SQLite, cached data, and the MCP binary behind. | Verify actual app data path and update `zap` entries accordingly | open |

Severity: **Critical** (unauth access to private data / cross-tenant leak / live secret / RCE) · **High** (auth bypass, missing tenant scope, secret in bundle, wildcard CORS+creds) · **Medium** (missing headers, info leak, high-CVE dep, reachable debug route) · **Low** (best-practice gap, no direct exploit).

Category: Public-exposure · Auth/tenant · Secrets/transport · Input/deps · Detection/abuse.

---

## Confirmed Secure

- 2026-06-15 — Both static download URLs use HTTPS. ✓
- 2026-06-15 — Formula tarball has a valid sha256 (`Formula/sleeper-manager.rb:6`). ✓
- 2026-06-15 — Cask zip has a valid sha256 (`Casks/sleeper-manager.rb:3`). ✓
- 2026-06-15 — No `system()` calls, `shell_output`, or `Utils.popen` in either Ruby file. ✓
- 2026-06-15 — No `using: :git` downloads; no `resource` blocks without checksums. ✓
- 2026-06-15 — No hardcoded credentials, API keys, or tokens in any file or git history. ✓
- 2026-06-15 — No pipe-to-shell patterns (`curl | sh`, `wget | bash`). ✓
- 2026-06-15 — No Ruby-level `eval`, `IO.popen`, or `PTY` calls. ✓
- 2026-06-15 — Dependabot is configured in sleeper-api-mcp (the MCP source repo). ✓

---

## Untested / Needs Setup

- Verify that the sha256 values in both Formula and Cask match the actual artifacts currently at the download URLs.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
