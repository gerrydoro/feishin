# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Critical Build & Run
- This is a monorepo-like Electron application structure using `electron-vite`.
- Development: Use `pnpm run dev` for the full Electron app.
- Remote: `pnpm run dev:remote` for the web-only remote interface.
- Builds: Use `pnpm run build` (builds both Electron and Remote). 
- Note: The app architecture separates Main, Preload, and Renderer. Ensure imports respect this boundary (IPC communication).

## Project Specific Patterns
- UI: Uses Mantine v9.
- State: Uses Zustand for store management.
- Data fetching: Uses TanStack Query (React Query) v5.
- Shared code: `src/shared/` contains utilities, components, and hooks used across contexts (Electron/Web).
- Translations: Uses `i18next`. Run `pnpm run i18next` to update translation keys after adding new strings.
- Themes: Custom theme system in `src/shared/themes/`. New themes require adding a file here and updating `app-theme.ts`.

## Gotchas
- MPV binary: Desktop client requires a path to the MPV binary provided by the user in settings.
- IPC: Communication between Main/Renderer MUST be handled through Electron IPC. Avoid direct access to Node.js APIs in the renderer.
- SUID Sandbox (Linux): If encountering SUID sandbox errors on Linux, ensure user namespaces are enabled or `chrome-sandbox` has correct permissions (`chmod 4755`).
- Docker: Environment variables are used for initial configuration of the Docker container (see `README.md` for `SERVER_LOCK`, `PUBLIC_PATH`, etc.).
