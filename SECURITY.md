# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the `security-hardening` skill). Findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** Public Homebrew tap distributing the Sleeper Manager CLI Formula and macOS Cask · **Prod:** `https://github.com/yonimoore-it/homebrew-tap` · **Stack:** Homebrew Ruby DSL (`.rb` Formula + Cask); artifacts hosted on `artifacts.darthworks.io` / `sleeper.darthworks.io`

**Last audit:** 2026-07-15 · **Scope of run:** own asset, read-only / non-destructive static analysis.

---

## Open Findings

| ID | Sev | Category | Location (file:line) | Finding | Fix | Status |
|----|-----|----------|----------------------|---------|-----|--------|
| HT-01 | High | Input/deps | `Formula/sleeper-manager.rb:47-51` | The install script downloads the MCP binary (`sleeper-mcp`, ~95 MB) at runtime via `curl -fL# "$MCP_URL" -o "$MCP_BIN"` with no SHA-256 verification. The binary is immediately made executable and run. If `artifacts.darthworks.io` is compromised or the artifact is tampered with in transit, end users silently execute attacker-controlled code. (OWASP A08:2025 Software Integrity Failures / CWE-494 Download of Code Without Integrity Check.) | Compute and hardcode the SHA-256 of the current MCP binary in the Formula. Add a `shasum -a 256 -c` check immediately after the download: `echo "<expected-sha256>  $MCP_BIN" \| shasum -a 256 -c \|\| { rm -f "$MCP_BIN"; echo "✗ Integrity check failed."; exit 1; }`. Alternatively, bundle or version-pin the binary inside the tarball itself (the content-addressed Formula already pins the tarball). | open |
| HT-02 | Low | Public-exposure | `homebrew-tap/` root | No `.gitignore` present. The tap currently contains only `.rb` files with no secrets, but an accidental commit of a `.dev.vars`, `.env`, or token file would have no safety net. | Add a `.gitignore` with at minimum: `.env`, `.env.*`, `.dev.vars`, `*.pem`, `*.key`. | open |

---

## Confirmed Secure

- 2026-07-15 — Formula source tarball and macOS Cask zip both have hardcoded `sha256` digests (`a04a3180…` and `4d43ef0e…`), so the Homebrew installer verifies those downloads via content-addressing. ✓
- 2026-07-15 — No hardcoded secrets, API keys, or credentials in either `.rb` file. Download URLs use `https://`. ✓
- 2026-07-15 — This is a distribution-only tap; no server-side code, no auth surface, no database. ✓

---

## Untested / Needs Setup

- **Artifact server integrity (HT-01):** Whether `artifacts.darthworks.io` enforces HTTPS-only, has a valid TLS cert, and restricts write access is a server configuration concern, not visible from the tap source. Verify separately.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
| — | — | — | — |
