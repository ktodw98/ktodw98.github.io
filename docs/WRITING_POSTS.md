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

포스트 이미지는 아래 위치를 기본 경로로 사용합니다.

```text
assets/images/posts/<post_id>/
```

`post_id`는 생성 시 UUID로 자동 발급되는 불변 식별자입니다. 제목이나 slug를 바꿔도 이미지 경로는 유지됩니다.

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

현재 draft 글 보기:

```bash
make drafts
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

스터디 노트 생성:

```bash
make new TEMPLATE=study-note TITLE="MSA 01 - What Are Microservices?" CATEGORY=engineering TAGS="architecture,microservices,study" SERIES="msa-study" SERIES_ORDER=1 DESCRIPTION="챕터 핵심 개념과 내 해석 정리"
```

대표 이미지까지 같이 넣는 예시:

```bash
make new TEMPLATE=case-study TITLE="Reducing API Tail Latency" CATEGORY=backend TAGS="api,performance,latency" DESCRIPTION="지연 시간 병목을 줄인 과정" IMAGE="cover.png"
```

## front matter 규칙

필수 필드:

```yaml
---
title: "Post title"
date: 2026-03-10 17:00:00 +0900
post_id: "550e8400-e29b-41d4-a716-446655440000"
type: "article"
categories: ["engineering"]
tags: ["architecture", "decision"]
description: "한 줄 요약"
draft: true
---
```

규칙:

- `type`: `article`, `tutorial`, `case-study`, `log`, `reference` 중 하나
- `post_id`: UUID 형식의 불변 식별자. 생성 시 자동 발급되며 수정하지 않는다.
- `categories`: 정확히 1개, `_data/taxonomies.yml`에 존재해야 함
- `tags`: 1개 이상 5개 이하, 소문자 kebab-case만 허용
- `description`: 목록/검색/메타 설명에 쓰이는 한 줄 요약
- `draft`: 초안은 `true`, 발행은 `false`
- `series`와 `series_order`: 연재형 글일 때만 같이 사용
- `image`: 선택값. `cover.png` 같은 상대 파일명, `/assets/images/...` 절대 경로, 또는 `http/https` URL을 사용할 수 있다.
- 상대 파일명 이미지는 자동으로 `assets/images/posts/<post_id>/` 아래에서 찾고, 해당 글의 OG 이미지로 사용한다.

스터디 포스트 운영 규칙:

- 스터디 노트도 일반 포스트와 같은 위치와 규칙으로 관리합니다.
- 같은 학습 묶음이면 동일한 `series` 값을 사용하고, 순서대로 `series_order`를 증가시킵니다.
- 카테고리는 스터디 주제에 맞게 `engineering`, `backend`, `frontend` 등에서 선택합니다.
- `study-note` 템플릿은 생성 시 `SERIES`와 `SERIES_ORDER`가 필수입니다.

## 본문 작성 규칙

- 템플릿에 들어 있는 섹션은 시작점이다. 필요 없는 섹션은 삭제하고, 필요한 섹션은 추가한다.
- 첫 문단은 제목 반복이 아니라 글의 문제와 결론 방향을 보여줘야 한다.
- 태그는 자유 입력 가능하지만, 먼저 `make tags`에 있는 추천 목록을 재사용하는 편이 좋다.
- 카테고리는 글의 소속, 태그는 검색/발견용 보조 키워드로 생각한다.
- 새 글을 만들면 `assets/images/posts/<post_id>/` 디렉터리도 같이 생성된다.
- 대표 이미지는 전용 디렉터리에 두고 `image: "cover.png"`처럼 상대 파일명으로 적는다.
- 본문 이미지는 아래 helper로 넣는다.

```liquid
{% include post-image.html file="step-01.png" alt="캐시 계층 구조도" caption="요청 흐름 개요" %}
```

- helper는 현재 글의 `post_id`를 기준으로 실제 이미지 URL을 계산한다.
- 본문에서 `/assets/images/posts/...` 같은 절대경로를 직접 박아 넣는 방식은 지양한다.
- 스터디 글은 `Overview -> Key Concepts -> Notes -> Takeaways` 흐름으로 쓰면 읽기와 복습이 쉽다.

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
- `post_id`는 자동 생성되며, 발행 후에도 바꾸지 않는 값입니다.
- `tags`는 최대 5개입니다.
- `series`만 넣고 `series_order`를 빼면 validation이 실패합니다.
- `study-note` 생성 시 `SERIES` 또는 `SERIES_ORDER` 하나만 넣으면 생성이 실패합니다.
- slug는 제목에서 자동 생성되므로, 특수문자가 많으면 `SLUG=...`를 직접 주는 편이 안전합니다.
- `image: "cover.png"` 같은 상대 파일명을 썼다면 실제 파일도 `assets/images/posts/<post_id>/cover.png`에 있어야 validation이 통과합니다.
- 생성 직후 기본값은 `draft: true`입니다. 발행 전에 직접 바꿔야 합니다.
- 발행 전에 `make drafts`로 초안 목록에서 빠지는지 확인하는 편이 안전합니다.
