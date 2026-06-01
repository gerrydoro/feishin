# Architect Mode AGENTS.md

- Monorepo Boundaries: Strict Main/Preload/Renderer separation to maintain Electron security.
- IPC Pattern: All cross-process communication must be strictly defined in IPC handlers; avoid direct backend calls from Renderer.
- Theme System: Custom theme architecture (`src/shared/themes/`) requires centralized registration in `app-theme.ts` for accessibility/consistency.
- Performance: Use TanStack Query persistence and Zustand efficiently to handle large music library state.
