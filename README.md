# jdgrid.com

`jdgrid.com` 루트 도메인의 정적 portfolio 사이트.

## 파일 구조

```
.
├── index.html          메인 랜딩 (yutils 프로젝트 카드)
├── about/index.html    About
├── privacy/index.html  Privacy Policy
├── terms/index.html    Terms of Service
├── robots.txt
└── sitemap.xml
```

- 인라인 CSS, 외부 의존성 0
- 라이트 + 다크 모드 자동 (`prefers-color-scheme`)
- 모바일 반응형
- 총 ~25 KB

URL 은 extension-less (`/about`, `/privacy`, `/terms`) — Cloudflare Pages 가
`about/index.html` 을 자동으로 `/about` 으로 서빙.

## 콘텐츠 업데이트

- 새 프로젝트 추가 시 `index.html` 의 `<main>` 안 새 `.project` 카드 추가
- 약관 변경 시 `privacy/index.html` / `terms/index.html` 의 "Last updated" 갱신
  + `sitemap.xml` lastmod 갱신
