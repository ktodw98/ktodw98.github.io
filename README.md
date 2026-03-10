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

## Post workflow

Use `make` as the entrypoint and let `scripts/posts.rb` generate the file.

List available presets:

```bash
make templates
```

List categories:

```bash
make categories
```

List recommended tags:

```bash
make tags
```

Create a new post:

```bash
make new TEMPLATE=tutorial TITLE="Building a Caching Layer" CATEGORY=backend TAGS="go,api,caching" DESCRIPTION="How the cache design evolved."
```

Create an external summary post:

```bash
make import-summary TITLE="Notes on Example Article" CATEGORY=writing TAGS="reference,writing" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="Summary and takeaways from the source article."
```

Create a repost skeleton:

```bash
make import-repost TITLE="Repost: Example Article" CATEGORY=writing TAGS="reference" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="Repost with source attribution."
```

Generated files are stored under `_posts/<category>/YYYY-MM-DD-slug.md`.

Required front matter:

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
- `categories`: exactly one value and it must exist in `_data/taxonomies.yml`
- `tags`: 1 to 5 values, lowercase kebab-case only
- `series` and `series_order`: optional, but must be set together when used
- imported posts must include `source_url`, `source_name`, and `import_mode`

Recommended template set:

- `article`
- `tutorial`
- `case-study`
- `log`
- `reference`
- `import-summary`
- `import-repost`

Reference other documents with wikilinks:

```md
See [[Welcome to My Dev Blog]] and [[Development Glossary]].
```

During build, wikilinks are converted to internal links and backlinks are generated automatically.

## Validation and deploy

Run the full local check:

```bash
make validate
```

Or run each step directly:

```bash
ruby scripts/validate-i18n.rb
ruby scripts/validate-frontmatter.rb
bundle exec jekyll build
```

Push to `main` to publish through GitHub Pages.

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

## Taxonomy master

Categories and recommended tags are centrally managed in `_data/taxonomies.yml`.

Each category has:

- `id`: stable machine id (slug)
- `label`: UI display name
- `description`: explanatory text
- `order`: sidebar ordering
- `active`: visibility toggle

Recommended tags are listed under `recommended_tags` and are used by the CLI as suggestions. They are not hard-blocked by validation.

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
