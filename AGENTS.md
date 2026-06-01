# AGENTS.md

This file provides guidance to agents when working with code in this repository.

- Architecture: Electron app with separated Main, Preload, and Renderer processes (enforce IPC boundaries).
- UI/State/Data: Mantine v9, Zustand, TanStack Query v5.
- Dependency Gotchas:
  - `node-mpv` is a custom git version (`github:jeffvli/Node-MPV`).
  - `react-window-v2` is an alias for `react-window`.
- MPV Binary: Desktop client requires user-configured path in settings.
- SUID Sandbox (Linux): If sandbox errors occur, ensure user namespaces enabled or `chrome-sandbox` has `4755` permissions.
