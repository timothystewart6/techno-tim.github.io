#!/bin/bash
# Check that every image referenced in _posts/ exists in Cloudflare R2.
# Also reports images in R2 that aren't referenced anywhere (orphans).
#
# Usage: ./tools/check-images.sh

set -euo pipefail

BUCKET="techno-tim-images"
REMOTE="r2"
POSTS_DIR="_posts"
TMP_REF=$(mktemp)
TMP_R2=$(mktemp)

echo "==> Scanning posts for image references..."
grep -roh '/assets/img/[^"'"'"' )]*' "$POSTS_DIR/" \
  | sed 's|.*:/assets/|/assets/|' \
  | sort -u > "$TMP_REF"

echo "==> Fetching R2 file list..."
rclone ls "$REMOTE:$BUCKET/assets/img/" \
  | awk '{print "/assets/img/"$2}' \
  | grep -v '^/assets/img/favicons/' \
  | sort -u > "$TMP_R2"

REFERENCED=$(wc -l < "$TMP_REF" | tr -d ' ')
IN_R2=$(wc -l < "$TMP_R2" | tr -d ' ')

echo ""
echo "  Referenced in posts : $REFERENCED"
echo "  Files in R2         : $IN_R2"
echo ""

# Images referenced in posts but missing from R2
MISSING=$(comm -23 "$TMP_REF" "$TMP_R2")
MISSING_COUNT=$(echo "$MISSING" | grep -c . || true)

if [ -z "$MISSING" ]; then
  echo "✅ All referenced images exist in R2."
else
  echo "❌ $MISSING_COUNT image(s) referenced in posts but MISSING from R2:"
  echo "$MISSING" | sed 's/^/   /'
  echo ""
  echo "To upload missing images (if you have them locally):"
  echo "   ./tools/upload-images.sh assets/img/"
fi

echo ""

# Images in R2 not referenced in any post (orphans)
ORPHANS=$(comm -13 "$TMP_REF" "$TMP_R2")
ORPHAN_COUNT=$(echo "$ORPHANS" | grep -c . || true)

if [ -z "$ORPHANS" ]; then
  echo "✅ No orphaned images in R2."
else
  echo "ℹ️  $ORPHAN_COUNT image(s) in R2 not referenced in any post (may be safe to delete):"
  echo "$ORPHANS" | sed 's/^/   /'
fi

rm -f "$TMP_REF" "$TMP_R2"
