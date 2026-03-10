# 게시글 작성 가이드

이 문서는 블로그 글을 실제로 쓰고 발행하는 운영 흐름을 정리합니다.

## 기본 흐름

1. 템플릿 목록 확인
2. category와 tags 결정
3. `make new` 또는 import 명령으로 초안 생성
4. 본문 작성
5. 로컬 검증
6. `main`에 push

## 파일 위치

생성된 글은 아래 경로에 저장됩니다.

```text
_posts/<category>/YYYY-MM-DD-slug.md
```

예시:

```text
_posts/backend/2026-03-10-building-a-caching-layer.md
```

## 작성 전 확인 명령

사용 가능한 템플릿 보기:

```bash
make templates
```

사용 가능한 category 보기:

```bash
make categories
```

추천 tag 보기:

```bash
make tags
```

## 새 글 생성

일반 글 생성:

```bash
make new TEMPLATE=article TITLE="How We Simplified Deployments" CATEGORY=infra TAGS="deployments,infra,workflow" DESCRIPTION="배포 흐름을 줄이면서 생긴 변화 정리"
```

튜토리얼 글 생성:

```bash
make new TEMPLATE=tutorial TITLE="Building a Caching Layer" CATEGORY=backend TAGS="go,api,caching" DESCRIPTION="캐시 계층을 설계하고 검증한 과정"
```

레퍼런스 글 생성:

```bash
make new TEMPLATE=reference TITLE="HTTP Cache Control Notes" CATEGORY=backend TAGS="reference,http,caching" DESCRIPTION="자주 헷갈리는 Cache-Control 규칙 정리"
```

## front matter 규칙

필수 필드:

```yaml
---
title: "Post title"
date: 2026-03-10 17:00:00 +0900
type: "article"
categories: ["engineering"]
tags: ["architecture", "decision"]
description: "한 줄 요약"
draft: true
---
```

규칙:

- `type`: `article`, `tutorial`, `case-study`, `log`, `reference` 중 하나
- `categories`: 정확히 1개, `_data/taxonomies.yml`에 존재해야 함
- `tags`: 1개 이상 5개 이하, 소문자 kebab-case만 허용
- `description`: 목록/검색/메타 설명에 쓰이는 한 줄 요약
- `draft`: 초안은 `true`, 발행은 `false`
- `series`와 `series_order`: 연재형 글일 때만 같이 사용

## 본문 작성 규칙

- 템플릿에 들어 있는 섹션은 시작점이다. 필요 없는 섹션은 삭제하고, 필요한 섹션은 추가한다.
- 첫 문단은 제목 반복이 아니라 글의 문제와 결론 방향을 보여줘야 한다.
- 태그는 자유 입력 가능하지만, 먼저 `make tags`에 있는 추천 목록을 재사용하는 편이 좋다.
- 카테고리는 글의 소속, 태그는 검색/발견용 보조 키워드로 생각한다.

내부 문서 참조 예시:

```md
관련 배경은 [[Development Glossary]]에서 먼저 정리했다.
```

## 검증과 발행

로컬 미리보기:

```bash
make preview
```

전체 검증:

```bash
make doctor
```

개별 실행:

```bash
ruby scripts/validate-i18n.rb
ruby scripts/validate-frontmatter.rb
bundle exec jekyll build
```

기존 `make validate`도 동작하지만, 표준 진입점은 `make doctor`입니다.

문제 없으면 `draft: false`로 바꾸고 `main`에 push 합니다.

## 실수하기 쉬운 규칙

- `categories`를 문자열 하나로 쓰면 안 되고 배열로 써야 합니다.
- `tags`는 최대 5개입니다.
- `series`만 넣고 `series_order`를 빼면 validation이 실패합니다.
- slug는 제목에서 자동 생성되므로, 특수문자가 많으면 `SLUG=...`를 직접 주는 편이 안전합니다.
- 생성 직후 기본값은 `draft: true`입니다. 발행 전에 직접 바꿔야 합니다.
