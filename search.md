---
layout: page
title: Search
permalink: /search/
description: Search posts by title, tag, and description.
---

<div class="search-box">
  <label for="search-input">Search query</label>
  <input id="search-input" type="search" placeholder="Try 'jekyll', 'workflow', or 'debug'" data-search-json="{{ '/search.json' | relative_url }}">
</div>

<ul id="search-results" class="search-results"></ul>

<script src="{{ '/assets/js/search.js' | relative_url }}"></script>
