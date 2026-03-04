///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.064 // WORKBOOK :: 0UT.3OX Site Deploy Notes ▞▞

# 1n3ox-temp — Site Deployment Notes

This folder now hosts a deploy-ready static landing page for **3ox.store**.

## Primary File

- `index.html` — complete single-page website content
  - landing paragraph for what 3OX.Ai is
  - architecture section for the 5-6-7-7-2 lattice
  - Get Started onboarding flow
  - GitHub links
  - portfolio highlights

## Deployment Targets

| Target | Method |
|--------|--------|
| **3ox.store** (VPS) | `./sync-3ox-store.sh` → rsync to CMD.VPS, nginx serves `/var/www/3ox.store` |
| GitHub Pages | Publish `index.html` as site root |

## VPS Hosting (3ox.store)

1. **Deploy**: From repo root, run `1n3ox-temp/sync-3ox-store.sh`
2. **VPS path**: `/var/www/3ox.store/` (or `/root/!CMD.VPS/3ox-store/`)
3. **Nginx**: See `!Z3N.PRO.OPS/DEPLOY.3OX.STORE.md` for server block config

## Notes

- Styling is inline for portability (single-file deploy).
- Content source references:
  - `3OX.Ai/PLAN.md`
  - `PORTFOLIO.md`

:: ∎

