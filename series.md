---
layout: page
title: Series
permalink: /series/
description: Browse serialized posts and progress.
---

{% assign series_posts = site.posts | where_exp: "item", "item.draft != true and item.series" %}
{% assign series_groups = series_posts | group_by: "series" | sort: "name" %}

{% if series_groups.size > 0 %}
  <ul class="post-archive-list series-index-list">
    {% for series in series_groups %}
      {% assign series_items = series.items | sort: "series_order" %}
      {% assign first_post = series_items | first %}
      {% assign latest_post = series_items | sort: "date" | last %}
      <li class="card series-card">
        <h2>{{ series.name }}</h2>
        <p class="meta">
          {{ series_items.size }} posts
          {% if latest_post %} · latest {{ latest_post.date | date: "%Y-%m-%d" }}{% endif %}
        </p>
        {% if first_post %}
          <p><a href="{{ first_post.url | relative_url }}">Start with {{ first_post.series_order }}. {{ first_post.title }}</a></p>
        {% endif %}
        <ol class="series-compact-list">
          {% for post in series_items %}
            <li>
              <a href="{{ post.url | relative_url }}">{{ post.series_order }}. {{ post.title }}</a>
            </li>
          {% endfor %}
        </ol>
      </li>
    {% endfor %}
  </ul>
{% else %}
  <p>No series configured yet.</p>
{% endif %}
