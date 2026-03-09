# Markdown Dev Blog (Jekyll + GitHub Pages)

This repository is a Markdown-first development blog template designed for:

- GitHub Pages deployment from `main`
- Custom domain support via `CNAME`
- Built-in global search, sidebars, dark mode, comments (Giscus), and analytics (GA4)
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
tags: ["tag1", "tag2"]
description: "One-line summary"
draft: false
---
```

4. Push to `main` to publish.

## Write a note (knowledge graph style)

1. Create a file in `_notes/` (for example: `_notes/my-note.md`)
2. Use front matter:

```yaml
---
title: "My Note"
tags: ["notes", "reference"]
description: "Quick summary"
draft: false
---
```

3. Reference other documents with wikilinks:

```md
See [[Welcome to My Dev Blog]] and [[Development Glossary]].
```

During build, wikilinks are converted to internal links and backlinks are generated automatically.

## Site structure

- `/` Home dashboard
- `/posts/` Post archive
- `/notes/` Note archive
- `/about/` About page
- Header search input for global search
- Left sidebar for tags and navigation
- Right sidebar (post/note) for TOC, related posts, backlinks
- `/feed.xml` Atom feed

## Feature notes

- **Comments**: Giscus renders only after `giscus.repo_id` and `giscus.category_id` are configured.
- **Analytics**: GA4 script loads only when `ga4_measurement_id` is replaced from default placeholder.
- **Edit on GitHub**: every page/post includes an edit link based on `_config.yml` GitHub settings.
- **Wikilinks**: `[[Page Title]]` and `[[Page Title|Alias]]` are supported for posts/notes/pages.
