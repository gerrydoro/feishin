# Debug Mode AGENTS.md

- MPV Issues: Often caused by missing/misconfigured binary path in user settings.
- IPC Failures: Usually silent in Renderer; check Main process logs or wrap IPC handlers in try/catch.
- SUID Sandbox: If `chrome-sandbox` errors appear on Linux, `chmod 4755` is the required fix.
