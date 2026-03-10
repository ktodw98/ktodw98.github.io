---
layout: page
title: Categories
permalink: /categories/
description: Browse posts by category.
---

{% assign active_categories = site.data.taxonomies.categories | where: "active", true | sort: "order" %}

{% if active_categories.size > 0 %}
  <ul class="post-archive-list categories-index-list">
    {% for category in active_categories %}
      {% assign category_posts = site.posts | where_exp: "item", "item.draft != true and item.categories and item.categories contains category.id" %}
      <li class="card category-card">
        <h2><a href="{{ '/categories/' | append: category.id | append: '/' | relative_url }}">{{ category.label }}</a></h2>
        <p class="meta">{{ category_posts.size }} posts · /{{ category.id }}</p>
        <p>{{ category.description }}</p>
        <p class="meta"><a href="{{ '/posts/' | relative_url }}?category={{ category.id | url_encode }}">Open filtered posts view</a></p>
      </li>
    {% endfor %}
  </ul>
{% else %}
  <p>No active categories configured.</p>
{% endif %}
