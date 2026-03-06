# 3D Print Cost Calculator Website (GitHub Pages)

Static marketing site for the app, intended for the `gh-pages` branch.

## Structure

- `index.html` - landing page
- `privacy.html` - privacy policy page
- `terms.html` - terms page
- `assets/logo` - logo/favicons
- `assets/screenshots` - app screenshots
- `assets/store-badges` - app store badges
- `assets/styles` - CSS

## Local Preview

From this branch root:

```bash
python3 -m http.server 8080
```

Then open `http://localhost:8080`.

## Deploy via GitHub Pages

1. Push this branch to `origin/gh-pages`.
2. In GitHub repo settings, set Pages source to `Deploy from a branch`.
3. Select branch `gh-pages` and folder `/ (root)`.
4. Save. GitHub will publish the static site.

## Notes

- Site is static (no backend).
- No framework dependencies.
- Store badges and screenshots are local assets.
- App pricing is intentionally omitted because it varies by region.
