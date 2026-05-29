# SECURITY.md — homebrew-tap

> Posture audit tracker (maintained by the `security-hardening` skill). Findings land here, remediations are logged, never overwrite — merge.

**Intended posture:** Public Homebrew third-party tap for personal macOS tooling distribution · **Prod:** Yes — end-user macOS installs via `brew install --cask` · **Stack:** Ruby DSL cask formula, binary hosted at sleeper.darthworks.io

**Last audit:** 2026-05-29 · **Scope of run:** own asset, read-only / non-destructive static analysis.

---

## Open Findings

| ID | Sev | Category | Location (file:line) | Finding | Fix | Status |
|----|-----|----------|----------------------|---------|-----|--------|
| HT-01 | Medium | Public-exposure | `Casks/sleeper-manager.rb:5` | Download URL points to `https://sleeper.darthworks.io/downloads/sleeper-manager-mac.zip` — a versionless first-party server path. SHA256 is pinned (checksum mismatch = install failure), but the URL has no version component. A future version bump could ship a mismatched SHA if only the formula is updated. Also, a server compromise before the SHA is updated would not be detected until after a user tries to install. | Move to versioned GitHub release assets: `https://github.com/yonimoore-it/sleeper-manager/releases/download/v#{version}/sleeper-manager-mac.zip` — version-locks URL by construction. | open |
| HT-02 | Low | Public-exposure | `Casks/sleeper-manager.rb` + README | Cask strips Gatekeeper quarantine (Homebrew default). The app is not Apple-notarized. Users bypass macOS code-signing checks at install time. | Sign and notarize `Sleeper Manager.app` with an Apple Developer ID. Add a `depends_on macos:` clause if minimum macOS is enforced. | open |

---

## Confirmed Secure

- 2026-05-29 — SHA256 checksum pinned (`299b51272e035a39771457641b6d3fd86f1d55eb4b4989bdda83ffd8007ca879`). Homebrew refuses install on mismatch. ✓
- 2026-05-29 — Download URL uses HTTPS. ✓
- 2026-05-29 — No hardcoded tokens or credentials in the formula. ✓
- 2026-05-29 — No `postinstall` shell execution in the cask formula itself. ✓
- 2026-05-29 — Single download URL is owner-controlled — no third-party CDN mirror dependencies. ✓
- 2026-05-29 — `name`, `desc`, and `homepage` fields present; formula is well-formed. ✓

---

## Untested / Needs Setup

- **Binary contents of `sleeper-manager-mac.zip`** — the app opens Terminal and runs an installer + uvicorn (per README). Installer script should be reviewed for privilege escalation, curl-pipe-to-shell patterns, or hardcoded credentials.
- **Server-side controls on `sleeper.darthworks.io/downloads/`** — confirm directory listing is disabled and path is not traversal-accessible.
- **Code-signing status** — `codesign --verify` and `spctl --assess` require the actual binary; untestable statically.

---

## Remediation Log

| Date | ID | What changed | Verified |
|------|----|--------------|----------|
| — | — | — | — |
