---
layout: page
title: Resume
permalink: /resume/
description: Profile, experience, skills, and contact information.
---

{% assign profile = site.author %}

## Summary

**{{ profile.name | default: "Your Name" }}**  
{{ profile.headline | default: "Software Engineer" }}

{{ profile.bio | default: "Write a short summary about your strengths, focus area, and impact." }}

## Contact

- Location: {{ profile.location | default: "Seoul, South Korea" }}
- Email: {% if profile.email %}[{{ profile.email }}](mailto:{{ profile.email }}){% else %}you@example.com{% endif %}
- GitHub: {% if profile.github_url %}[{{ profile.github_url }}]({{ profile.github_url }}){% else %}https://github.com/your-id{% endif %}
- LinkedIn: {% if profile.linkedin_url %}[{{ profile.linkedin_url }}]({{ profile.linkedin_url }}){% else %}https://www.linkedin.com/in/your-id{% endif %}

## Experience

### Company / Team (YYYY.MM - Present)
- Built and shipped production features with clear ownership.
- Improved reliability and developer productivity through automation.
- Documented architecture decisions and operating runbooks.

### Previous Company / Team (YYYY.MM - YYYY.MM)
- Led technical initiatives and delivered measurable user impact.
- Collaborated across product, design, and engineering.

## Skills

- Languages: Go, TypeScript, Python, SQL
- Platform: AWS, Docker, GitHub Actions, Linux
- Focus: Backend architecture, automation, reliability

## Projects

- [Dev Blog]({{ site.url }}): Markdown-first knowledge base with wikilinks and backlinks.
- Add your highlighted repositories and links here.
