# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the `security-hardening` skill). Findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** Public Homebrew tap distributing `sleeper-manager` CLI formula and macOS cask. · **Stack:** Homebrew Ruby formula + cask

**Last audit:** 2026-11-15 · **Scope of run:** own asset, read-only / non-destructive static analysis.

---

## Open Findings

| ID | Sev | Category | Location (file:line) | Finding | Fix | Status |
|----|-----|----------|----------------------|---------|-----|--------|
| F-01 | Medium | Input/deps | `Formula/sleeper-manager.rb:73` | The formula downloads the MCP binary at runtime via `curl -fL# "$MCP_URL" -o "$MCP_BIN"` from `https://artifacts.darthworks.io/sleeper/sleeper-mcp` **without verifying a SHA256 checksum**. If the CDN is compromised, the domain is hijacked, or the URL is redirected, users will silently install and execute an unverified ~95 MB binary. The source tarball (line 6) and the cask (Casks/sleeper-manager.rb) both have SHA256 checks — only this runtime download is unverified. | Pin the binary to a versioned URL that changes on each release, compute its SHA256, and add a verification step in the install script: `expected="<sha256>"; actual=$(sha256sum "$MCP_BIN" | awk '{print $1}'); [ "$actual" = "$expected" ] || { echo "✗ Checksum mismatch"; rm "$MCP_BIN"; exit 1; }`. Alternatively, embed the binary in the formula's source archive (increases formula size but removes the runtime fetch). | open |

---

## Confirmed Secure

- 2026-11-15 — Source tarball has SHA256 (`a04a3180…`) in formula — Homebrew verifies this at install time. ✓
- 2026-11-15 — macOS cask has SHA256 (`4d43ef0e…`) — Homebrew verifies before quarantine release. ✓
- 2026-11-15 — Formula downloads over HTTPS (`curl -fL#` with `-f` = fail on 4xx/5xx, `-L` = follow redirects). ✓
- 2026-11-15 — No secrets or credentials in formula or cask files. ✓
- 2026-11-15 — `zap` in cask cleans up `~/sleeper-manager` and `~/Library/Caches/sleeper-manager` on uninstall. ✓

---

## Untested / Needs Setup

- **CDN `artifacts.darthworks.io` access control** — confirm the R2/CDN bucket serving the MCP binary is not publicly writable; write access would allow silent binary replacement.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
