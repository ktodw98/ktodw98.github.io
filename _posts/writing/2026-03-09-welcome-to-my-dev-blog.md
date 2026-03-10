---
title: "Welcome to My Dev Blog"
date: 2026-03-09 21:30:00 +0900
post_id: "9ae18343-0531-474f-8de1-029015ba92d7"
type: "article"
categories: ["writing"]
tags: ["intro", "blogging", "workflow"]
series: "blog-setup"
series_order: 1
description: "Why this blog exists and how posts are managed with Markdown and GitHub."
draft: false
---

This is the first post in the blog.

The writing workflow is intentionally simple:

1. Run `make new TEMPLATE=article TITLE="..." CATEGORY=writing TAGS="..."`.
2. Fill in the generated front matter and template sections.
3. Run local validation before pushing to `main`.

This setup keeps content in Git history, easy to review, and easy to roll back.

If you want quick definitions and reference pointers, check [[Development Glossary]].
