# 템플릿 관리 가이드

이 문서는 게시글 템플릿을 추가하거나 수정하는 방법을 설명합니다.

## 현재 구조

템플릿 파일은 아래 디렉터리에 있습니다.

```text
templates/posts/
```

현재 기본 프리셋:

- `article`
- `tutorial`
- `case-study`
- `log`
- `reference`
- `study-note`
- `import-summary`
- `import-repost`

목록 확인:

```bash
make templates
```

## 새 템플릿 추가 절차

1. `templates/posts/<name>.md` 파일 생성
2. front matter placeholder 유지
3. 본문 섹션 프리셋 작성
4. `make templates`로 노출 확인
5. `make new TEMPLATE=<name> ...`로 실제 생성 테스트

예시:

```bash
touch templates/posts/retrospective.md
make templates
make new TEMPLATE=retrospective TITLE="Sprint 12 Review" CATEGORY=career SUBCATEGORY=teamwork TAGS="retrospective,team" DESCRIPTION="스프린트 회고"
```

주의:

- 새 템플릿 파일만 추가해도 `make templates`에는 자동 노출됩니다.
- 하지만 `scripts/posts.rb`의 `TYPE_BY_TEMPLATE`와 설명 기본값 매핑이 없으면 생성이 실패하거나 의도와 다르게 동작할 수 있습니다.

## placeholder 규칙

템플릿은 아래 placeholder를 사용합니다.
front matter 안에서는 YAML-safe 토큰을 권장합니다.

- `__TITLE__`
- `__DATE__`
- `__TYPE__`
- `__CATEGORY__`
- `# __SUBCATEGORY_BLOCK__`
- `__TAGS__`
- `__DESCRIPTION__`
- `# __IMAGE_BLOCK__`
- `__SERIES__`
- `__SERIES_ORDER__`
- `__SLUG__`
- `__SOURCE_URL__`
- `__SOURCE_NAME__`
- `__IMPORT_MODE__`

일반 템플릿은 보통 아래 6개만 사용합니다.

```md
__TITLE__
__DATE__
__TYPE__
__CATEGORY__
# __SUBCATEGORY_BLOCK__
__TAGS__
__DESCRIPTION__
# __IMAGE_BLOCK__
```

시리즈를 직접 front matter에 포함하는 템플릿은 아래 placeholder를 추가로 사용합니다.

```md
__SERIES__
__SERIES_ORDER__
```

import 템플릿은 아래 3개를 추가로 사용합니다.

```md
__SOURCE_URL__
__SOURCE_NAME__
__IMPORT_MODE__
```

생성기인 `scripts/posts.rb`는 기존 `{{...}}` placeholder도 계속 치환합니다.
다만 새 템플릿이나 수정 작업에서는 YAML 파서와 편집기 preview 오탐을 피하기 위해 `__...__` 형식을 사용합니다.

## 템플릿 예시

가장 단순한 템플릿 예시:

```md
---
title: "__TITLE__"
date: "__DATE__"
type: "__TYPE__"
categories: ["__CATEGORY__"]
# __SUBCATEGORY_BLOCK__
tags: __TAGS__
description: "__DESCRIPTION__"
# __IMAGE_BLOCK__
draft: true
---

## Context

What problem does this post cover?
```

## 분류와 메타데이터 연동

템플릿에서 직접 category 목록을 관리하지 않습니다.

- category와 추천 tag: `_data/taxonomies.yml`
- 글 생성 로직: `scripts/posts.rb`
- 실제 검증: `scripts/validate-frontmatter.rb`

즉, 템플릿은 글의 구조를 담당하고, taxonomy와 validation은 별도 파일에서 중앙 관리합니다.

`study-note`처럼 시리즈를 기본 전제로 하는 템플릿은 생성기에서 `SERIES`와 `SERIES_ORDER`를 함께 받아야 합니다.

## 템플릿 수정 시 점검

수정 후 아래를 확인합니다.

```bash
make templates
make new TEMPLATE=article TITLE="Template Check" CATEGORY=essays SUBCATEGORY=writing TAGS="writing,workflow" DESCRIPTION="template smoke test"
make new TEMPLATE=study-note TITLE="MSA 01 - What Are Microservices?" CATEGORY=engineering SUBCATEGORY=architecture TAGS="architecture,microservices,study" SERIES="msa-study" SERIES_ORDER=1 DESCRIPTION="template smoke test"
make validate
```

생성 테스트 파일은 확인 후 직접 삭제하거나 유지 여부를 결정합니다.

## 실수하기 쉬운 규칙

- placeholder 철자가 다르면 치환되지 않고 그대로 남습니다.
- 새 템플릿을 추가하면서 `TYPE_BY_TEMPLATE`를 안 맞추면 `type` 기본값이 의도와 다를 수 있습니다.
- `# __SUBCATEGORY_BLOCK__`를 빼면 `SUBCATEGORY=...`를 넘겨도 front matter에 반영되지 않습니다.
- `# __IMAGE_BLOCK__`를 빼면 생성기에서 `IMAGE=...`를 넘겨도 front matter에 반영되지 않습니다.
- `__SERIES__`와 `__SERIES_ORDER__`를 사용하는 템플릿은 생성기 입력도 같이 맞춰야 합니다.
- import 전용 placeholder를 일반 템플릿에 섞으면 빈 문자열로 치환될 수 있습니다.
- 템플릿은 ASCII 위주로 유지하는 편이 diff와 재사용에 유리합니다.
