# Markdown Dev Blog (Jekyll + GitHub Pages)

This repository is a Markdown-first development blog template designed for:

- GitHub Pages deployment from `main`
- Custom domain support via `CNAME`
- Built-in global search, category/series navigation, sidebars, dark mode, comments (Giscus), and analytics (GA4)
- Obsidian-style `[[wikilink]]` and automatic backlinks

## Quick start

1. Create GitHub repo: `YOUR_GITHUB_ID.github.io`
2. Copy this project and push to `main`
3. Edit placeholders in:
   - `_config.yml`
   - `CNAME`
4. Enable GitHub Pages (GitHub Actions source)

Detailed domain and HTTPS steps are in [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

## Local development

```bash
bundle install
bundle exec jekyll serve --livereload
```

Open: `http://127.0.0.1:4000`

## Write a new post

1. Copy `POST_TEMPLATE.md`
2. Save as `_posts/YYYY-MM-DD-your-title.md`
3. Fill required front matter:

```yaml
---
title: "Post title"
date: 2026-03-09 22:00:00 +0900
type: "article" # article | tutorial | case-study | log | reference
categories: ["engineering"]
tags: ["tag1", "tag2"]
description: "One-line summary"
draft: false
---
```

Metadata rules:

- `type`: required, must be one of `article`, `tutorial`, `case-study`, `log`, `reference`
- `categories`: exactly one value and it must exist in `_data/categories.yml`
- `tags`: 1 to 5 values, lowercase kebab-case only
- `series` and `series_order`: optional, but must be set together when used

4. Push to `main` to publish.

Reference other documents with wikilinks:

```md
See [[Welcome to My Dev Blog]] and [[Development Glossary]].
```

During build, wikilinks are converted to internal links and backlinks are generated automatically.

## Site structure

- `/` Home dashboard
- `/posts/` Post archive
- `/categories/` Category index
- `/categories/<id>/` Category detail (generated at build time)
- `/series/` Series index
- `/resume/` Resume / profile page
- `/about/` legacy alias to resume
- Header search input for global search
- Posts section sub-navigation for category shortcuts
- Left sidebar for profile, tags, and recent posts
- Right sidebar (post) for TOC, related posts, backlinks
- `/feed.xml` Atom feed

## UI i18n (Phase 1)

- UI locale only (`ko`, `en`, `ja`, `vi`) with single URL strategy.
- Configure defaults in `_config.yml`:
  - `default_locale`
  - `supported_locales`
- Locale dictionaries live in `_data/i18n/*.yml`.
- User selection is stored in `localStorage` (`blog-locale`).

## Category master

Categories are centrally managed in `_data/categories.yml`.

Each category has:

- `id`: stable machine id (slug)
- `label`: UI display name
- `description`: explanatory text
- `order`: sidebar ordering
- `active`: visibility toggle

## Validation

Run validation before publishing:

```bash
ruby scripts/validate-i18n.rb
ruby scripts/validate-frontmatter.rb
```

The CI workflow runs i18n/front matter validation before `jekyll build`.

## Feature notes

- **Comments**: Giscus renders only after `giscus.repo_id` and `giscus.category_id` are configured.
- **Analytics**: GA4 script loads only when `ga4_measurement_id` is replaced from default placeholder.
- **Edit on GitHub**: every page/post includes an edit link based on `_config.yml` GitHub settings.
- **Wikilinks**: `[[Page Title]]` and `[[Page Title|Alias]]` are supported for posts/pages.
