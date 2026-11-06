#!/usr/bin/env bash
# Builds the download page into _site/: fills the placeholders in index.html
# and draws the QR code for the APK link.
#
# Used by release-apk.yml (after every release) and pages.yml (when only the
# page changed), so both publish the same page.
#
# Needs qrencode (apt-get install qrencode) and:
#   VERSION       release version, e.g. 1.3.0
#   DATE          release date as shown on the page, e.g. 2026-10-12
#   SHA256        checksum of the APK
#   DOWNLOAD_URL  link to the newest APK
set -euo pipefail
: "${VERSION:?}" "${DATE:?}" "${SHA256:?}" "${DOWNLOAD_URL:?}"

mkdir -p _site
cp .github/pages/index.html _site/index.html
qrencode -o _site/qr.png -s 8 -m 2 "$DOWNLOAD_URL"

sed -i \
  -e "s|__DOWNLOAD_URL__|$DOWNLOAD_URL|g" \
  -e "s|__VERSION__|$VERSION|g" \
  -e "s|__DATE__|$DATE|g" \
  -e "s|__SHA256__|$SHA256|g" \
  _site/index.html

if grep -q '__[A-Z0-9_]*__' _site/index.html; then
  echo "::error::Unfilled placeholder in index.html"
  exit 1
fi
