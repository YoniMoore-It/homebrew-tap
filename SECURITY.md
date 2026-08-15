# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the security-hardening skill). Findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** public Homebrew tap · **Prod:** https://github.com/YoniMoore-It/homebrew-tap · **Stack:** Homebrew Formula (shell + Python venv) + Homebrew Cask (macOS .app zip)

**Last audit:** 2026-08-15 · **Scope of run:** own asset, read-only / non-destructive static analysis only.

---

## Open Findings

| ID | Sev | Category | Location (file:line or URL) | Finding | Fix | Status |
|----|-----|----------|------------------------------|---------|-----|--------|
| HB-01 | High | Input/deps | `Formula/sleeper-manager.rb:30,73` | Runtime MCP binary download has no integrity verification. `curl -fL# "$MCP_URL" -o "$MCP_BIN" && chmod +x "$MCP_BIN"` fetches `https://artifacts.darthworks.io/sleeper/sleeper-mcp` (~95 MB) and immediately makes it executable. HTTPS protects transit, but a compromise of `artifacts.darthworks.io` would deliver a malicious executable to every new install with no way to detect it. | Record a known-good sha256 in the formula and verify with `sha256sum -c` before `chmod +x`. Alternatively, version-stamp and content-address the binary so it can be baked into a `resource` block and verified by Homebrew's own integrity check. | open |
| HB-02 | Medium | Input/deps | `Formula/sleeper-manager.rb:65` | `pip install -r "$APP/backend/requirements.txt"` runs at first-run without `--require-hashes`. If any dependency uses a version range, PyPI could resolve to a compromised release between formula authoring and user install. | Regenerate `requirements.txt` with `pip-compile --generate-hashes` (pip-tools) and add `--require-hashes` to the install command. | open |

Severity: **Critical** · **High** · **Medium** · **Low**

---

## Confirmed Secure

- 2026-08-15 — All download URLs use HTTPS: formula source tarball, cask zip, and runtime MCP binary. No plain-HTTP download URLs. ✓
- 2026-08-15 — SHA-256 checksums present on both formula source tarball and cask zip; both are valid 64-hex-character digests. ✓
- 2026-08-15 — Formula shell script opens with `set -uo pipefail`; all shell variables are double-quoted; no unquoted expansion or injection vector found. ✓
- 2026-08-15 — No hardcoded secrets, API keys, tokens, or credentials found in any `.rb` file. ✓
- 2026-08-15 — No CI/workflow files present in the tap — no GitHub Actions surface to audit for secret injection. ✓
- 2026-08-15 — No `.gitignore` needed (tap contains only formula/cask `.rb` files and `README.md`). ✓
- 2026-08-15 — `pip install` uses the venv's own Python (`$APP/.venv/bin/python`) — dependency blast radius is contained to `~/.sleeper-manager`. ✓
- 2026-08-15 — No `eval`, no backtick command substitution, no `$()` on user-controlled data in the install or start script. ✓

---

## Untested / Needs Setup

- **requirements.txt hash-pinning**: Cannot inspect `requirements.txt` without unpacking the source tarball. Re-audit after confirming whether any dependency uses an unpinned version specifier (HB-02 severity depends on this).
- **`artifacts.darthworks.io` server posture**: Separate posture audit of that host (TLS config, write access controls) would fully characterize the HB-01 blast radius.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
