---
name: seo-consistency-check
description: jdgrid.com 4 페이지(index/about/privacy/terms)의 SEO·analytics 태그 정합성과 sitemap.xml 의 URL/lastmod, privacy·terms 본문 "Last updated" 날짜를 한 번에 검증한다. GA(G-SXG67JYJVK)·AdSense(ca-pub-1005049417920340) ID 누락, canonical URL 불일치, sitemap의 lastmod 포맷 오류, 본문 Last updated 가 sitemap lastmod 보다 미래인 날짜 역전, GA 로더 중복 삽입을 잡는다. 다음 경우 반드시 사용 — 페이지에 분석/메타 태그를 넣거나 뺀 직후, sitemap.xml 을 수정한 후, 새 페이지를 추가한 직후, "SEO 검증/메타 태그 정합성/GA 태그 확인/sitemap 점검/태그 일관성/캐노니컬 확인/analytics 점검/하네스 검증" 류 요청 시. 단순 본문 텍스트만 수정한 경우엔 불필요.
---

# seo-consistency-check

jdgrid.com 의 메타·analytics 태그가 4 페이지 사이에서 일관되게 유지되는지 검증한다. 정적 사이트라 빌드 단계가 없어 일관성 검사가 사람 손에 의존하므로, 이 스킬이 빌드 게이트 역할을 한다.

## 무엇을 검사하는가

### 페이지별 (index.html, about/index.html, privacy/index.html, terms/index.html)

| 검사 항목 | 통과 조건 |
|----------|----------|
| GA 로더 | `gtag/js?id=G-SXG67JYJVK` 가 정확히 1회 (중복 금지) |
| GA config | `gtag('config', 'G-SXG67JYJVK')` 호출 존재 |
| AdSense meta | `name="google-adsense-account"` + `content="ca-pub-1005049417920340"` |
| canonical | `rel="canonical" href="..."` 가 페이지 경로와 일치. 모든 경로에 trailing slash (Cloudflare Workers 가 `/about` → 307 → `/about/` 으로 자동 정규화하므로 canonical 도 `/about/` 형식) |
| 브랜드 접미사 | `<title>` 끝이 ` — jdgrid` 또는 시작이 `jdgrid` (index 의 경우) |
| description | `<meta name="description"` 존재 (내용 검증은 안 함) |

### sitemap.xml

- 4 URL `<loc>` 모두 존재 — `https://jdgrid.com/`, `/about/`, `/privacy/`, `/terms/` (trailing slash 필수)
- 모든 `<lastmod>` 가 `YYYY-MM-DD` 포맷 + 미래 날짜 아님

### Last updated 정합성 (privacy/terms 본문)

- `<p class="meta">Last updated: YYYY-MM-DD</p>` 존재 + 미래 아님
- 본문 `Last updated` ≤ sitemap `<lastmod>` of same URL

  본문 = 법적 내용이 마지막으로 바뀐 날, sitemap = URL 콘텐츠(메타 포함) 가 마지막으로 바뀐 날. 메타만 바뀐 경우 sitemap 만 갱신되므로 sitemap 이 항상 같거나 더 최신이어야 함.

## 실행

```
bash .claude/skills/seo-consistency-check/scripts/check.sh
```

종료 코드: 0 = 통과 (warning 만 있어도 0), 1 = 실패. 출력은 페이지별 `[파일명]` 헤더 + `FAIL`/`WARN` 라인 + 최종 요약.

## 실패 시 일반 원인 ↔ 수정

| 실패 메시지 | 원인 | 수정 |
|-----------|------|-----|
| `GA async loader missing or wrong ID` | 새 페이지 추가 후 GA 스니펫 누락 | 기존 페이지 head 의 GA 블록(`<script async src=...gtag/js?id=G-SXG67JYJVK>` + dataLayer/gtag config 두 줄) 복붙 |
| `AdSense meta missing or wrong ID` | 같은 패턴, AdSense meta 누락 | `<meta name="google-adsense-account" content="ca-pub-1005049417920340" />` 추가 |
| `canonical mismatch` | 새 페이지 카피 후 canonical 깜빡 | 페이지 경로와 일치시킴. 모든 경로 trailing slash (Cloudflare Workers 자동 정규화에 맞춤) |
| `duplicate GA loader` | 복붙 사고로 GA 로더 두 번 삽입 | 한 블록 삭제 |
| `sitemap missing <loc>` | 페이지 추가 후 sitemap 등록 누락 | sitemap.xml 에 `<url>` 블록 추가 |
| `sitemap lastmod malformed` | `2026/05/22` 같은 변형 입력 | `YYYY-MM-DD` 통일 |
| `Last updated newer than sitemap lastmod` | 약관 본문 날짜만 바꾸고 sitemap 깜빡 | `legal-doc-update` 스킬로 한 번에 처리 |
| `Last updated in the future` | 시계 어긋남 또는 오타 | 오늘 또는 과거 날짜로 수정 |

## 상수 변경 (GA·AdSense ID 교체 시)

스크립트가 페이지에서 ID 를 추출해 비교하는 대신 잠긴 상수와 대조하는 이유 — "잘못된 값이지만 4 페이지가 일관된" 사고도 잡기 위함. 정답을 스크립트가 갖고 있어야 함.

ID 가 바뀌면:
1. `scripts/check.sh` 상단의 `GA_ID`, `ADSENSE` 상수 갱신
2. 4 페이지 모두에서 해당 값 일괄 치환 (Edit `replace_all`)
3. 본 SKILL.md 의 description 의 ID 도 갱신
4. 스킬 재실행으로 통과 확인

## 함께 보기

- `legal-doc-update` — privacy/terms 본문 변경 시 Last updated + sitemap lastmod 동시 갱신
