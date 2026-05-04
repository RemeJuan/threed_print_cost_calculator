# 3D Print Cost Calculator Website (GitHub Pages)

Static marketing site for the app, built with Eleventy and intended for GitHub Pages.

## Structure

- `index.njk` - landing page source
- `privacy.njk` - privacy policy page source
- `terms.njk` - terms page source
- `changelog.njk` - changelog page source (renders `main` branch `CHANGELOG.md`)
- `roadmap/index.njk` - public roadmap page source
- `_includes` - shared layouts and partials
- `_data` - shared site data
- `assets/logo` - logo/favicons
- `assets/screenshots` - app screenshots
- `assets/store-badges` - app store badges
- `assets/styles` - CSS

## Local Preview

Install deps, then build or run local dev server:

```bash
npm install
npm run build
python3 -m http.server 8080 -d _site
```

Or use:

```bash
npm run dev
```

Then open `http://localhost:8080`.

## Deploy via GitHub Pages

Use the included GitHub Actions workflow.

1. In GitHub repo settings, set Pages source to `GitHub Actions`.
2. Push changes.
3. GitHub Actions will build Eleventy output and deploy it to Pages.

## Notes

- Site is static (no backend).
- Eleventy is build-time only; published output remains plain static files.
- Store badges and screenshots are local assets.
- App pricing is intentionally omitted because it varies by region.
- `CNAME` and `.nojekyll` are copied through to the final Pages artifact.
