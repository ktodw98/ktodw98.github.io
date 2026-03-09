---
layout: page
title: Tags
permalink: /tags/
description: Browse posts by tags.
---

{% assign sorted_tags = site.tags | sort %}
{% if sorted_tags.size > 0 %}
  <ul class="tag-index">
    {% for tag in sorted_tags %}
      <li><a href="#{{ tag[0] | slugify }}">#{{ tag[0] }}</a> ({{ tag[1].size }})</li>
    {% endfor %}
  </ul>

  {% for tag in sorted_tags %}
    <section id="{{ tag[0] | slugify }}" class="tag-section">
      <h2>#{{ tag[0] }}</h2>
      <ul>
        {% assign posts = tag[1] | where_exp: "item", "item.draft != true" %}
        {% for post in posts %}
          <li>
            <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
            <span class="meta">{{ post.date | date: "%Y-%m-%d" }}</span>
          </li>
        {% endfor %}
      </ul>
    </section>
  {% endfor %}
{% else %}
  <p>No tags yet.</p>
{% endif %}
