# jdgrid.com 랜딩 페이지

`jdgrid.com` 루트 도메인용 정적 사이트. AdSense 심사를 위한 portfolio + Privacy/Terms 페이지.

## 파일 구조

```
jdgrid-landing/
├── index.html       — 메인 랜딩 (yutils 프로젝트 카드)
├── about.html       — About
├── privacy.html     — Privacy Policy (AdSense 필수)
├── terms.html       — Terms of Service
├── robots.txt       — 검색엔진 크롤 허용
└── sitemap.xml      — 4 URL
```

- 단일 파일, 인라인 CSS, 외부 의존성 0
- 라이트 + 다크 모드 자동 (`prefers-color-scheme`)
- 모바일 반응형
- 총 ~25 KB

## 배포 (Cloudflare Pages 권장)

### 방법 A — Direct upload

1. https://dash.cloudflare.com → Workers & Pages → Create application → Pages → Direct upload
2. 프로젝트 이름: `jdgrid-landing` (또는 `jdgrid`)
3. 이 `jdgrid-landing/` 폴더 전체 drag & drop
4. Deploy 클릭

### 방법 B — Git 연동 (별도 repo 권장)

이 폴더를 별도 repo (예: `pplenty/jdgrid-landing`) 로 분리 후:

1. Cloudflare Pages → Create application → Connect to Git
2. Build settings: framework preset = None, build command = (empty), output directory = `/`
3. Deploy

### 커스텀 도메인 연결

배포 후:

1. Pages project → Custom domains → Set up a custom domain
2. `jdgrid.com` 입력 → DNS 자동 설정 (Cloudflare nameserver 가정)
3. `yutils.jdgrid.com` 은 그대로 — yutils worker 가 계속 처리
4. 잠시 대기 후 https://jdgrid.com 접속 확인

## AdSense 등록 절차

1. 위 배포 완료 후 https://jdgrid.com 접속 가능 확인
2. AdSense → Sites → Add site → `jdgrid.com` 입력
3. 심사 대기 (1-3 일, 길면 2 주)
4. 통과 후 광고 코드를 `index.html` `<head>` 에 박을 수 있음
5. 광고는 yutils.jdgrid.com 에서도 자동으로 동작 (같은 root 도메인)

## 콘텐츠 업데이트

- 새 프로젝트 추가 시 `index.html` 의 `<main>` 안 새 `.project` 카드 추가
- 약관 변경 시 `privacy.html`/`terms.html` 의 "Last updated" 갱신 + `sitemap.xml` lastmod 갱신

## 참고

- yutils.jdgrid.com 은 별도 (Next.js + Cloudflare Workers) — 영향 없음
- 이 랜딩은 단순 정적 사이트라 Workers 한도와 무관
- AdSense ads.txt 는 심사 통과 후 AdSense 가 안내하는 파일을 `jdgrid-landing/ads.txt` 로 추가
