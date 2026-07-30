---
name: legal-doc-update
description: jdgrid.com 의 privacy 또는 terms 약관의 **법적 내용** 을 수정했을 때 본문 `<p class="meta">Last updated: YYYY-MM-DD</p>` 와 sitemap.xml 의 해당 URL `<lastmod>` 를 같은 오늘 날짜로 동기화. 보유 데이터 항목·연락처·면책 조항·사용자 권리 등 약관 텍스트 변경 후 반드시 사용. "privacy/terms 갱신", "약관 수정", "Last updated 갱신", "법적 고지 업데이트", "이용약관 변경", "개인정보처리방침 수정", "사이트맵 lastmod 동기화" 류 요청을 트리거. 메타 태그·analytics·디자인만 바뀐 경우엔 본 스킬이 아니라 sitemap lastmod 만 갱신 (본문 Last updated 는 법적 내용 변경일 표시이므로 건드리지 않음). 마무리에 `seo-consistency-check` 로 검증.
---

# legal-doc-update

privacy 또는 terms 의 **법적 내용** 을 바꿨을 때, 본문 `Last updated` 와 sitemap `<lastmod>` 를 같은 오늘 날짜로 맞춘다.

## 두 날짜는 의미가 다르다

| 위치 | 의미 | 언제 갱신 |
|------|------|----------|
| 본문 `<p class="meta">Last updated: YYYY-MM-DD</p>` | **법적 정책 자체가 바뀐 날** — 이용자 권리·의무·데이터 처리 변경 시점 | 약관 텍스트가 실질적으로 바뀔 때만 |
| sitemap `<lastmod>` | URL 콘텐츠가 마지막으로 수정된 날 — 메타 태그·analytics 만 바뀌어도 갱신 | 모든 변경에서 |

따라서 메타 태그만 바꿨을 때는 sitemap `<lastmod>` 만 갱신하고 본문 Last updated 는 건드리지 않는다. 본 스킬은 **법적 내용 변경** 시점에만 동작.

## 워크플로우

1. **변경 대상 식별** — privacy 만, terms 만, 또는 둘 다
2. **오늘 날짜 확인** — `date +%Y-%m-%d`
3. **본문 Last updated 갱신** — 각 변경 파일에 대해 Edit:
   - `<p class="meta">Last updated: {이전 날짜}</p>` → `<p class="meta">Last updated: {오늘}</p>`
   - 이전 날짜는 파일에서 직접 읽어 확인 (이 줄은 파일당 1회만 등장하므로 unique)
4. **sitemap.xml 의 해당 URL lastmod 갱신** — 각 변경 URL 에 대해 Edit:
   - `<loc>` 줄을 컨텍스트로 포함시켜 매칭 unique 확보 (sitemap 에 같은 lastmod 가 여러 URL 에 등장하므로)
5. **검증** — `bash .claude/skills/seo-consistency-check/scripts/check.sh` 로 통과 확인

## Edit 패턴 (정확히 이대로)

**본문 — `privacy/index.html` (terms 도 동일 패턴)**:
```
old_string: <p class="meta">Last updated: 2026-05-20</p>
new_string: <p class="meta">Last updated: 2026-05-22</p>
```

**sitemap.xml — privacy 의 lastmod 갱신 시** (`<loc>` 한 줄 컨텍스트로 unique 확보):
```
old_string:
    <loc>https://jdgrid.com/privacy/</loc>
    <lastmod>2026-05-22</lastmod>
new_string:
    <loc>https://jdgrid.com/privacy/</loc>
    <lastmod>2026-05-23</lastmod>
```

terms 의 경우 동일 패턴, `<loc>` 만 `/terms/` 로 바꾼다. URL 은 trailing slash 형식 — Cloudflare Workers 가 extension-less URL 을 trailing slash 로 자동 정규화하므로 일치시킴.

## 루트(`/`) lastmod 는 건드리지 않는다

약관 변경은 홈페이지 콘텐츠가 바뀐 것이 아니다. 4 페이지 전체 lastmod 동기화는 *글로벌 메타 변경* (예: 모든 페이지에 GA 삽입) 시에만 적용. 약관 변경 시 sitemap 에서 갱신하는 것은 약관 URL 의 `<lastmod>` 만.

## 커밋 메시지 컨벤션

git log 의 약관/sitemap 커밋 패턴을 따른다:
- `chore(legal): privacy/terms — {변경 요약} (Last updated YYYY-MM-DD)`
- `chore(sitemap): lastmod 갱신 — YYYY-MM-DD ({사유})`

법적 내용 변경은 한 커밋에 본문+sitemap 을 함께 묶는다 (분리 시 sitemap-only 커밋이 의미 없는 lastmod 변경처럼 보임).

## 흔한 실수

- **본문만 바꾸고 sitemap 깜빡** — `seo-consistency-check` 가 `Last updated newer than sitemap lastmod` 로 잡아준다. 5번 단계로 검증.
- **sitemap 만 바꾸고 본문 깜빡** — 법적 내용 변경이라면 본문이 진짜 변경일. sitemap 은 *최소한* 본문과 같거나 더 늦어야 함. `seo-consistency-check` 가 잡지는 못함(반대 방향이라). 워크플로우 3단계를 절대 건너뛰지 말 것.
- **본문 Last updated 를 메타 변경으로 갱신** — 법적 내용이 안 바뀐 단순 GA 삽입 같은 작업으로 Last updated 를 갱신하면 이용자에게 "약관이 바뀌었다" 는 잘못된 신호를 준다. 메타 전용 변경은 sitemap 만.

## 함께 보기

- `seo-consistency-check` — 갱신 직후 정합성 확인용 검증 스크립트
