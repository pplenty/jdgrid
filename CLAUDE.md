# jdgrid.com

`jdgrid.com` 정적 portfolio 사이트. 4 HTML 페이지 (`index` / `about` / `privacy` / `terms`), Cloudflare Pages 배포, 인라인 CSS, 외부 의존성 0, 빌드 단계 없음.

## 하네스: jdgrid (skills-only, zero agents)

**목표:** 4 페이지 사이의 SEO·analytics 태그 정합성과 약관·sitemap 날짜 동기화를 자동화한다. 정적 사이트 규모 상 전문 에이전트는 두지 않고 main agent 가 직접 스킬을 호출.

**트리거:**
- 메타 태그·analytics 스니펫·sitemap.xml 변경 직후 → `seo-consistency-check` 스킬 실행 (4 페이지 정합성·GA/AdSense ID·canonical·sitemap lastmod·본문 Last updated 역전 검사)
- privacy/terms 의 **법적 내용** 변경 시 → `legal-doc-update` 스킬 호출 (본문 Last updated + sitemap lastmod 동시 갱신). 메타·디자인만 바뀐 경우는 sitemap lastmod 만 갱신하고 본문 Last updated 는 건드리지 않음
- 단순 본문/디자인 수정, easter egg 튜닝, 콘텐츠 카드 추가는 직접 처리

**구성:**
- `.claude/skills/seo-consistency-check/` — 4 페이지 SEO/analytics/sitemap 정합성 검증 (bash 스크립트 동봉, `bash .claude/skills/seo-consistency-check/scripts/check.sh` 로 실행)
- `.claude/skills/legal-doc-update/` — 약관 변경 시 Last updated + sitemap lastmod 동기화 워크플로우

**원칙:**
- 두 날짜는 의미가 다르다 — 본문 `Last updated` = 법적 정책 변경일, sitemap `<lastmod>` = URL 콘텐츠 변경일. 메타 전용 변경은 sitemap 만.
- 잠긴 상수 (GA `G-SXG67JYJVK`, AdSense `ca-pub-1005049417920340`) 가 4 페이지에서 일치해야 함. 변경 시 `seo-consistency-check/scripts/check.sh` 상단 상수와 4 페이지를 함께 수정.
- 새 페이지 추가 시 sitemap.xml 에 `<url>` 블록 등록 + GA/AdSense/canonical 스니펫 복붙 + `seo-consistency-check` 재실행.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-05-22 | 초기 구성 — skills-only 하네스 (zero agents) | `seo-consistency-check`, `legal-doc-update` | 최근 GA 통합(2026-05-22) + AdSense + sitemap lastmod 동시 관리 부담 ↑. 4 페이지 정적 사이트 규모로는 스킬 2개로 충분, 에이전트는 과 |
