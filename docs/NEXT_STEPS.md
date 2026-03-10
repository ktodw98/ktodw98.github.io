# 다음 우선순위

현재 블로그 구조를 기준으로 다음 작업 우선순위를 정리합니다.

## 1. `make preview`

목적:

- 로컬 프리뷰 진입점을 표준화
- `bundle exec jekyll serve --livereload`를 외우지 않아도 되게 함

## 2. `make doctor`

목적:

- i18n 검증
- front matter 검증
- Jekyll build

한 번에 실행해서 배포 전 점검 루틴을 단순화합니다.

## 3. draft 운영 보강

목적:

- 초안 목록 확인 흐름 추가
- `draft: true` 글을 어떻게 관리할지 문서화

후보:

- `make drafts`
- draft 전용 목록 페이지 또는 로컬 전용 노출

## 4. 대표 이미지 체계

목적:

- OG 이미지 기본값
- 포스트 썸네일 기본 규칙
- SNS 공유 시 시각 품질 확보

## 5. 템플릿 프리셋 강화

목적:

- `tutorial`, `case-study`, `reference`별 기본 섹션을 더 구체화
- 작성자가 타입별 기대 구조를 바로 따를 수 있게 함

## 6. import 보호장치 강화

목적:

- 원문 링크 미입력 시 더 명확한 실패 메시지
- `repost` 생성 시 저작권/허가 경고 강화

## 7. 콘텐츠 인덱스 고도화

목적:

- category, series, archive 탐색성 개선
- 글이 많아졌을 때 탐색 비용을 줄임

후보:

- 연도별 archive
- 인기 태그 정리
- series overview 카드 강화
