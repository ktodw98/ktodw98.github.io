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
      {% assign primary_category = post.categories | first %}
      {% capture category_label %}{% include category-label.html id=primary_category %}{% endcapture %}
      <li class="card" data-tags="{{ post.tags | join: '|' | downcase }}" data-category="{{ primary_category | downcase }}">
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <p class="meta">
          {{ post.date | date: "%Y-%m-%d" }}
          {% if primary_category %} · {{ category_label | strip }}{% endif %}
          {% if post.tags and post.tags.size > 0 %} · {{ post.tags | join: ", " }}{% endif %}
        </p>
        <p>{{ post.description }}</p>
      </li>
    {% endfor %}
  </ul>
{% else %}
  <p>No posts yet.</p>
{% endif %}
