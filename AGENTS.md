# AGENTS.md

## Repo shape
- Static GitHub Pages site. No package manager, build, lint, test, or typecheck config in repo.
- Main pages: `index.html`, `privacy.html`, `terms.html`, `changelog.html`, `roadmap/index.html`.
- Shared styling: `assets/styles/site.css`.

## Preview and verification
- Preview from repo root with `python3 -m http.server 8080`.
- Use `http://localhost:8080`, not `file://`. `changelog.html` fetches remote Markdown and pages rely on relative links.
- Verification is manual: load homepage, legal pages, roadmap, and changelog; check desktop + narrow mobile width because nav drawer behavior changes at `680px`.

## Deploy / publishing constraints
- Repo content is intended for GitHub Pages branch root.
- Keep `CNAME` (`printcostcalc.app`) and `.nojekyll`; both matter for Pages hosting.

## Page wiring / gotchas
- `roadmap/index.html` is only nested page. Its assets and internal links use `../...`; root pages use `...`.
- Mobile nav JS is inline and duplicated in `index.html` and `roadmap/index.html`. If nav behavior or links change, update both files.
- `changelog.html` does not read local content. It fetches `CHANGELOG.md` from `RemeJuan/threed_print_cost_calculator` `main` via raw GitHub, then jsDelivr fallback, and renders with CDN `marked`.
- `changelog.html` intentionally strips rendered links by replacing every `<a>` inside changelog content with plain text spans after Markdown render.

## Editing guidance
- Prefer editing HTML + `assets/styles/site.css` directly; no component system or templating layer.
- Keep marketing copy and support/social/store links consistent across homepage, footer, roadmap, and legal pages; these are duplicated by hand.
