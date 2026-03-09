# Deployment and Domain Checklist

## 1) GitHub repository setup

1. Create a repository named `YOUR_GITHUB_ID.github.io`.
2. Push this project to the `main` branch.
3. In repository settings:
   - Enable **GitHub Pages** with **GitHub Actions** as the source.
   - Confirm the workflow `.github/workflows/pages.yml` is active.

## 2) Required configuration edits

Update `_config.yml` placeholders:

- `url`: set your production URL.
- `github.owner`, `github.repo`, `github.branch`.
- `ga4_measurement_id`: set your GA4 measurement ID.
- `giscus.*`: set repo, repo_id, category, category_id.

Update `CNAME` with your actual domain.

## 3) DNS setup for custom domain

### For apex domain (example: `example.com`)

Add `A` records pointing to GitHub Pages IP addresses:

- `185.199.108.153`
- `185.199.109.153`
- `185.199.110.153`
- `185.199.111.153`

### For subdomain (example: `blog.example.com`)

Add one `CNAME` record:

- Host: `blog`
- Value: `YOUR_GITHUB_ID.github.io`

## 4) HTTPS verification checklist

1. Open repository settings > Pages.
2. Ensure custom domain is recognized.
3. Enable **Enforce HTTPS**.
4. Validate with browser:
   - `https://your-domain` loads without certificate warnings.
   - `http://your-domain` redirects to `https://`.

## 5) Runtime verification checklist

After each `main` push:

1. Pages workflow passes.
2. Home, post detail, tags, and search pages load.
3. Dark mode toggle works.
4. Giscus comments render on post detail pages.
5. GA4 real-time view receives page events.
