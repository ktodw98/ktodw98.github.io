# Markdown Dev Blog (Jekyll + GitHub Pages)

Markdown 중심으로 운영하는 개발 블로그 템플릿입니다.

- `main` 푸시 기반 GitHub Pages 배포
- 커스텀 도메인 + `CNAME` 지원
- 검색, category/series 탐색, 사이드바, 다크모드, Giscus, GA4 포함
- `[[wikilink]]`와 backlink 지원

## Quick Start

```bash
bundle install
bundle exec jekyll serve --livereload
```

브라우저: `http://127.0.0.1:4000`

초기 설정은 아래를 먼저 수정합니다.

- `_config.yml`
- `CNAME`

배포/도메인 설정은 [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)를 참고합니다.

## Main Commands

```bash
make preview
make doctor
make drafts
make templates
make categories
make tags
make new TEMPLATE=tutorial TITLE="Building a Caching Layer" CATEGORY=engineering SUBCATEGORY=backend TAGS="go,api,caching" DESCRIPTION="How the cache design evolved." IMAGE="cover.png"
make new TEMPLATE=study-note TITLE="MSA 01 - What Are Microservices?" CATEGORY=engineering SUBCATEGORY=architecture TAGS="architecture,microservices,study" SERIES="msa-study" SERIES_ORDER=1 DESCRIPTION="Chapter summary and takeaways."
make import-summary TITLE="Notes on Example Article" CATEGORY=essays SUBCATEGORY=writing TAGS="reference,writing" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="Summary and takeaways from the source article." IMAGE="cover.png"
make import-repost TITLE="Repost: Example Article" CATEGORY=essays SUBCATEGORY=writing TAGS="reference" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="Repost with source attribution." IMAGE="cover.png"
make validate
```

## Docs

- [docs/WRITING_POSTS.md](docs/WRITING_POSTS.md): 새 글 작성, 메타데이터 규칙, 검증, 발행 방법
- [docs/MANAGING_TEMPLATES.md](docs/MANAGING_TEMPLATES.md): 템플릿 등록/수정 방식과 placeholder 규칙
- [docs/IMPORTING_CONTENT.md](docs/IMPORTING_CONTENT.md): 외부 글 요약/import 운영 규칙
- [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md): 다음 우선순위 백로그
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md): 커스텀 도메인/HTTPS/Pages 배포

## Structure

- `/` Home
- `/posts/` Post archive
- `/categories/` Category index
- `/categories/<category>/` Category detail
- `/categories/<category>/<subcategory>/` Subcategory detail
- `/series/` Series index
- `/resume/` Resume page
- `/feed.xml` Atom feed

게시물은 `_posts/<category>/YYYY-MM-DD-slug.md`에 저장됩니다.

포스트 이미지는 `assets/images/posts/<post_id>/`에 저장됩니다. `post_id`는 생성 시 UUID로 자동 발급되며, 제목이나 slug가 바뀌어도 그대로 유지됩니다.

## Validation

```bash
make doctor
```

하위 호환 명령:

```bash
make validate
```

직접 실행:

```bash
ruby scripts/validate-i18n.rb
ruby scripts/validate-frontmatter.rb
bundle exec jekyll build
```

## Notes

- UI 다국어는 `ko`, `en`, `ja`, `vi`를 지원하며 단일 URL 전략을 사용합니다.
- taxonomy는 `_data/taxonomies.yml`에서 중앙 관리합니다.
- `subcategory`는 선택값이며, 활성화된 category 아래에서만 지정할 수 있습니다.
- 기본 OG 이미지는 `/assets/images/og-default.png`를 사용하고, 개별 글에서 `image: "cover.png"` 같은 상대 파일명으로 덮어쓸 수 있습니다.
- 본문 이미지는 `{% include post-image.html file="step-01.png" alt="..." caption="..." %}` 형식으로 삽입합니다.
- `media_baseurl`를 설정하면 포스트 이미지 URL을 외부 스토리지/CDN으로 쉽게 이관할 수 있습니다.
- Giscus는 `giscus.repo_id`, `giscus.category_id` 설정 후 렌더링됩니다.
- GA4는 `_config.yml`의 `ga4_measurement_id` 교체 후 활성화됩니다.
