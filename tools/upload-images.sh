#!/bin/bash
# Upload images to Cloudflare R2, preserving path structure.
#
# Usage:
#   ./tools/upload-images.sh <local-path>
#
# Examples:
#   ./tools/upload-images.sh assets/img/posts/my-new-post/     # upload a folder
#   ./tools/upload-images.sh assets/img/headers/new-hero.webp  # upload a single file
#   ./tools/upload-images.sh assets/img/                       # upload everything

set -euo pipefail

BUCKET="techno-tim-images"
REMOTE="r2"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <local-path>"
  echo ""
  echo "Examples:"
  echo "  $0 assets/img/posts/my-new-post/"
  echo "  $0 assets/img/headers/new-hero.webp"
  echo "  $0 assets/img/  (sync everything)"
  exit 1
fi

LOCAL_PATH="$1"

if [ -f "$LOCAL_PATH" ]; then
  DEST_DIR="$(dirname "$LOCAL_PATH")"
  echo "==> Uploading file: $LOCAL_PATH"
  echo "==> Destination:    $REMOTE:$BUCKET/$DEST_DIR/"
  echo ""
    rclone copy "$LOCAL_PATH" "$REMOTE:$BUCKET/$DEST_DIR/" --s3-no-check-bucket --dry-run --progress
  echo ""
  read -p "Proceed with upload? (y/N) " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rclone copy "$LOCAL_PATH" "$REMOTE:$BUCKET/$DEST_DIR/" --s3-no-check-bucket --progress
    echo "==> Done!"
  else
    echo "==> Cancelled."
  fi
elif [ -d "$LOCAL_PATH" ]; then
  echo "==> Uploading directory: $LOCAL_PATH"
  echo "==> Destination:         $REMOTE:$BUCKET/$LOCAL_PATH"
  echo ""
    rclone copy "$LOCAL_PATH" "$REMOTE:$BUCKET/$LOCAL_PATH" --s3-no-check-bucket --dry-run --progress
  echo ""
  read -p "Proceed with upload? (y/N) " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rclone copy "$LOCAL_PATH" "$REMOTE:$BUCKET/$LOCAL_PATH" --s3-no-check-bucket --progress
    echo "==> Done!"
  else
    echo "==> Cancelled."
  fi
else
  echo "Error: '$LOCAL_PATH' not found."
  exit 1
fi
