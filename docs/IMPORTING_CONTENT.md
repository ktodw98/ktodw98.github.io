# 외부 글 가져오기 가이드

이 문서는 다른 블로그나 문서를 참고해 글을 가져오는 운영 방법을 정리합니다.

## 두 가지 방식

### 1. `import-summary`

권장 기본값입니다.

- 원문을 요약하고
- 핵심 포인트를 정리하고
- 내 해석이나 비판, 후속 링크를 덧붙이는 방식입니다

생성 예시:

```bash
make import-summary TITLE="Notes on Example Article" CATEGORY=essays SUBCATEGORY=writing TAGS="reference,summary,writing" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="원문 요약과 내 해석"
```

### 2. `import-repost`

원문을 재게시하는 골격입니다.

- 출처와 재게시 고지를 반드시 포함해야 합니다
- 권리 확인이 된 경우에만 사용해야 합니다

생성 예시:

```bash
make import-repost TITLE="Repost: Example Article" CATEGORY=essays SUBCATEGORY=writing TAGS="reference,repost" SOURCE_URL="https://example.com/post" SOURCE_NAME="Example Blog" DESCRIPTION="재게시용 초안"
```

## 필수 메타데이터

import 글은 일반 글과 달리 아래 필드가 추가로 필요합니다.

```yaml
source_url: "https://example.com/post"
source_name: "Example Blog"
import_mode: "summary"
```

검증 규칙:

- `source_url`, `source_name`, `import_mode`는 반드시 같이 있어야 합니다
- `source_url`은 `http` 또는 `https` URL이어야 합니다
- `import_mode`는 `summary` 또는 `repost`만 허용됩니다

## 권장 운영 방식

- 기본은 `summary`를 사용합니다
- `repost`는 퍼가기 허용 범위와 저작권 상태를 직접 확인한 뒤에만 사용합니다
- 원문에서 중요한 문장을 길게 복사하기보다, 핵심 아이디어와 내 해석을 정리하는 쪽이 안전합니다

## 작성 흐름

1. 원문 URL과 출처명을 확인
2. `import-summary` 또는 `import-repost`로 초안 생성
3. 원문 링크와 출처 표기 확인
4. 내 요약/메모 또는 재게시 고지 작성
5. 검증 후 발행

## 템플릿 구조 차이

`import-summary`는 다음 섹션을 기본으로 제공합니다.

- `Source`
- `Summary`
- `Key Points`
- `My Notes`

`import-repost`는 다음 섹션을 기본으로 제공합니다.

- `Source Notice`
- `Original Content`

## 실수하기 쉬운 규칙

- 출처 URL 없이 import 글을 만들 수 없습니다
- `repost`는 기술적으로 생성 가능하더라도, 법적으로 허용된다는 뜻이 아닙니다
- category는 여전히 정확히 1개만 허용되며, subcategory는 필요할 때만 선택적으로 붙일 수 있습니다
- 추천 tag에 없는 값을 써도 되지만, `reference`, `summary`, `repost`, `writing` 같은 공통 태그를 우선 재사용하는 편이 좋습니다
