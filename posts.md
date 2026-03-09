---
layout: page
title: Posts
permalink: /posts/
description: Published posts sorted by date.
---

<p id="active-tag-filter" class="meta active-filter" hidden></p>

{% assign visible_posts = site.posts | where_exp: "item", "item.draft != true" %}
{% if visible_posts.size > 0 %}
  <ul id="post-archive-list" class="post-archive-list">
    {% for post in visible_posts %}
      <li class="card" data-tags="{{ post.tags | join: '|' | downcase }}">
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <p class="meta">{{ post.date | date: "%Y-%m-%d" }} · {{ post.tags | join: ", " }}</p>
        <p>{{ post.description }}</p>
      </li>
    {% endfor %}
  </ul>
{% else %}
  <p>No posts yet.</p>
{% endif %}
