#!/usr/bin/env bash
# SEO/analytics consistency check for jdgrid.com
# Verifies 4 static HTML pages + sitemap.xml are mutually consistent.
# No build step exists, so this script acts as the build gate.

set -uo pipefail

ROOT="${JDGRID_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
cd "$ROOT"

# --- Locked constants ---------------------------------------------------------
# Change here AND in all 4 HTML files together (Edit replace_all).
GA_ID="G-SXG67JYJVK"
ADSENSE="ca-pub-1005049417920340"
DOMAIN="jdgrid.com"
# -----------------------------------------------------------------------------

# pages: "file|expected_canonical"
PAGES=(
  "index.html|https://${DOMAIN}/"
  "about/index.html|https://${DOMAIN}/about/"
  "privacy/index.html|https://${DOMAIN}/privacy/"
  "terms/index.html|https://${DOMAIN}/terms/"
)

fail_count=0
warn_count=0
fail() { echo "  FAIL: $1"; fail_count=$((fail_count + 1)); }
warn() { echo "  WARN: $1"; warn_count=$((warn_count + 1)); }

check_page() {
  local file=$1 canonical=$2
  echo "[$file]"
  if [ ! -f "$file" ]; then
    fail "missing file"
    return
  fi

  grep -qF "gtag/js?id=${GA_ID}" "$file" \
    || fail "GA async loader missing or wrong ID (expected ${GA_ID})"

  grep -qF "gtag('config', '${GA_ID}')" "$file" \
    || fail "GA config call missing or wrong ID (expected ${GA_ID})"

  grep -qE "name=\"google-adsense-account\"[[:space:]]+content=\"${ADSENSE}\"" "$file" \
    || fail "AdSense meta missing or wrong ID (expected ${ADSENSE})"

  local actual_canonical
  actual_canonical=$(grep -oE 'rel="canonical" href="[^"]+"' "$file" | head -1 | sed -E 's/.*href="([^"]+)".*/\1/')
  if [ -z "$actual_canonical" ]; then
    fail "canonical link missing"
  elif [ "$actual_canonical" != "$canonical" ]; then
    fail "canonical mismatch: expected '$canonical', got '$actual_canonical'"
  fi

  grep -qE '<title>[^<]*— jdgrid</title>|<title>jdgrid' "$file" \
    || fail "title missing brand suffix '— jdgrid' (or 'jdgrid' prefix for index)"

  grep -q 'name="description"' "$file" \
    || fail "description meta missing"

  local loader_count
  loader_count=$(grep -c "gtag/js?id=" "$file" 2>/dev/null || echo 0)
  if [ "$loader_count" -gt 1 ]; then
    fail "duplicate GA loader ($loader_count occurrences)"
  fi
}

# --- 1. Per-page checks -------------------------------------------------------
for entry in "${PAGES[@]}"; do
  file=${entry%%|*}
  canonical=${entry##*|}
  check_page "$file" "$canonical"
done

# --- 2. Sitemap presence + format --------------------------------------------
echo "[sitemap.xml]"
if [ ! -f sitemap.xml ]; then
  fail "sitemap.xml missing"
else
  for url in "https://${DOMAIN}/" "https://${DOMAIN}/about/" "https://${DOMAIN}/privacy/" "https://${DOMAIN}/terms/"; do
    grep -qF "<loc>$url</loc>" sitemap.xml \
      || fail "sitemap missing <loc>$url</loc>"
  done

  today=$(date +%Y-%m-%d)
  while IFS= read -r d; do
    if ! [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      fail "sitemap lastmod malformed: '$d' (expect YYYY-MM-DD)"
      continue
    fi
    if [[ $d > $today ]]; then
      warn "sitemap lastmod in the future: $d (today $today)"
    fi
  done < <(grep -oE '<lastmod>[^<]+</lastmod>' sitemap.xml | sed -E 's/<\/?lastmod>//g')
fi

# --- 3. Last updated cross-check (privacy/terms) -----------------------------
echo "[Last updated dates]"
today=$(date +%Y-%m-%d)
for f in privacy/index.html terms/index.html; do
  if [ ! -f "$f" ]; then
    continue
  fi
  local_date=$(grep -oE 'Last updated: [0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | head -1 | awk '{print $3}')
  if [ -z "$local_date" ]; then
    fail "$f: 'Last updated: YYYY-MM-DD' not found in body"
    continue
  fi
  if [[ $local_date > $today ]]; then
    warn "$f: Last updated in the future: $local_date (today $today)"
  fi

  url_path=$(dirname "$f")
  target_url="https://${DOMAIN}/${url_path}/"
  sitemap_lastmod=$(awk -v u="$target_url" '
    $0 ~ ("<loc>" u "</loc>") { found=1; next }
    found && /<lastmod>/ {
      match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
      if (RSTART > 0) print substr($0, RSTART, RLENGTH)
      exit
    }
  ' sitemap.xml)

  if [ -z "$sitemap_lastmod" ]; then
    : # already reported by sitemap section if missing
  elif [[ $sitemap_lastmod < $local_date ]]; then
    fail "$f Last updated ($local_date) is newer than sitemap lastmod ($sitemap_lastmod) for $target_url"
  fi
done

# --- Summary ------------------------------------------------------------------
echo ""
if [ $fail_count -eq 0 ] && [ $warn_count -eq 0 ]; then
  echo "OK — all consistency checks passed"
  exit 0
elif [ $fail_count -eq 0 ]; then
  echo "OK — $warn_count warning(s), no failures"
  exit 0
else
  echo "FAILED — $fail_count failure(s), $warn_count warning(s)"
  exit 1
fi
