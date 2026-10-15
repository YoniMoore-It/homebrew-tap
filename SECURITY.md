# SECURITY.md — homebrew-tap

**Intended posture:** public (Homebrew formula/cask distribution) · **Stack:** Ruby `.rb` Homebrew formulae + shell install scripts

**Last audit:** 2026-10-15 · **Scope of run:** own asset, read-only / non-destructive static audit.

---

## Open Findings

| ID | Sev | Category | Location (file:line or URL) | Finding | Fix | Status |
|----|-----|----------|------------------------------|---------|-----|--------|
| SEC-1 | Medium | Secrets/transport | `Formula/sleeper-manager.rb:72` | The MCP binary (`$MCP_URL = "https://artifacts.darthworks.io/sleeper/sleeper-mcp"`) is downloaded at first run with `curl -fL#` but no SHA-256 integrity check follows. A compromised `artifacts.darthworks.io` could serve a malicious binary that runs silently with user privileges on the first `sleeper-manager start`. | After the `curl` download, add: `echo "<known-sha256>  $MCP_BIN" \| shasum -a 256 -c - \|\| { echo "✗ MCP binary checksum mismatch"; rm -f "$MCP_BIN"; exit 1; }` and update the expected hash on each release. | open |

Severity: **Critical** (unauth access to private data / cross-tenant leak / live secret / RCE) · **High** (auth bypass, missing tenant scope, secret in bundle, wildcard CORS+creds) · **Medium** (missing headers, info leak, high-CVE dep, reachable debug route) · **Low** (best-practice gap, no direct exploit).

Category: Public-exposure · Auth/tenant · Secrets/transport · Input/deps.

---

## Confirmed Secure

- 2026-10-15 — `Formula/sleeper-manager.rb`: source tarball has a `sha256` checksum verified by Homebrew at install time. ✓
- 2026-10-15 — `Casks/sleeper-manager.rb`: `.zip` artifact has a `sha256` checksum verified by Homebrew at install time. ✓
- 2026-10-15 — No hardcoded API keys, tokens, or passwords anywhere in the repository. ✓
- 2026-10-15 — Install script does not use `shell=True` / eval on user input; shell variable expansion is controlled. ✓
- 2026-10-15 — No `.gitignore` needed (no secrets committed; no build output or `.env` files). ✓

---

## Untested / Needs Setup

- `artifacts.darthworks.io` TLS certificate validity (server not probed in this run).

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
