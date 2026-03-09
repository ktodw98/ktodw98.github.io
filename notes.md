---
layout: page
title: Notes
permalink: /notes/
description: Evergreen notes connected with wikilinks and backlinks.
---

{% assign visible_notes = site.notes | where_exp: "item", "item.draft != true" %}
{% if visible_notes.size > 0 %}
  <ul class="post-archive-list">
    {% for note in visible_notes %}
      <li class="card">
        <h2><a href="{{ note.url | relative_url }}">{{ note.title }}</a></h2>
        {% if note.tags and note.tags.size > 0 %}
          <p class="meta">{{ note.tags | join: ", " }}</p>
        {% endif %}
        <p>{{ note.description | default: note.excerpt | strip_html | truncate: 140 }}</p>
      </li>
    {% endfor %}
  </ul>
{% else %}
  <p>No notes yet.</p>
{% endif %}
