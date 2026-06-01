# Code Mode AGENTS.md

- STRICT IPC: Never import Electron/Node.js modules directly in Renderer. Use Preload/IPC context bridging.
- Translations: New strings must run `pnpm run i18next` to sync keys.
- Theme System: New themes in `src/shared/themes/`, update `app-theme.ts`.
- Polymorphic Components: Use `src/shared/utils/create-polymorphic-component.ts` for consistent typed components.
