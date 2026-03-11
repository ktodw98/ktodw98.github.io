---
layout: page
title: Posts
permalink: /posts/
description: Published posts sorted by date.
---

{% assign visible_posts = site.posts | where_exp: "item", "item.draft != true" %}
{% if visible_posts.size > 0 %}
  <div class="posts-view-root is-view-card" data-posts-view-root>
    <div class="posts-view-toolbar">
      <p id="active-tag-filter" class="meta active-filter" hidden></p>
      <div class="posts-view-switcher">
        <span class="posts-view-label" data-i18n="posts_view.label">View</span>
        <div class="posts-view-buttons" role="group" aria-label="Post view mode" data-i18n-aria-label="aria.posts_view_mode">
          <button type="button" class="posts-view-button" data-posts-view-option="text" aria-pressed="false" data-i18n="posts_view.text">Text</button>
          <button type="button" class="posts-view-button is-active" data-posts-view-option="card" aria-pressed="true" data-i18n="posts_view.card">Card</button>
          <button type="button" class="posts-view-button" data-posts-view-option="compact" aria-pressed="false" data-i18n="posts_view.compact">Compact</button>
        </div>
      </div>
    </div>
    <ul id="post-archive-list" class="post-archive-list">
      {% for post in visible_posts %}
        {% assign primary_category = post.categories | first %}
        {% assign post_subcategory = post.subcategory | default: "" %}
        {% assign card_image = post.image | default: "" %}
        {% capture taxonomy_label %}{% include taxonomy-label.html category_id=primary_category subcategory_id=post_subcategory %}{% endcapture %}
        <li class="card post-card{% if card_image != '' and card_image != site.image %} post-card--with-image{% endif %}" data-tags="{{ post.tags | join: '|' | downcase }}" data-category="{{ primary_category | downcase }}" data-subcategory="{{ post_subcategory | downcase }}">
          {% if card_image != '' and card_image != site.image %}
            <a class="post-card-media" href="{{ post.url | relative_url }}" aria-hidden="true" tabindex="-1">
              <img class="post-card-image" src="{{ card_image }}" alt="" loading="lazy" decoding="async">
            </a>
          {% endif %}
          <div class="post-card-body">
            <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
            <p class="meta">
              {{ post.date | date: "%Y-%m-%d" }}
              {% if primary_category %} · {{ taxonomy_label | strip }}{% endif %}
              {% if post.tags and post.tags.size > 0 %} · {{ post.tags | join: ", " }}{% endif %}
            </p>
            <p>{{ post.description }}</p>
          </div>
        </li>
      {% endfor %}
    </ul>
  </div>
{% else %}
  <p>No posts yet.</p>
{% endif %}
