#!/bin/bash
# Pull all images from Cloudflare R2 to local disk.
# Useful after a fresh clone or to sync images locally for previewing with jekyll serve.
#
# Usage: ./tools/pull-images.sh

set -euo pipefail

BUCKET="techno-tim-images"
REMOTE="r2"

echo "==> Pulling images from R2 to assets/img/ ..."
rclone copy "$REMOTE:$BUCKET/assets/img/" assets/img/ --progress
echo "==> Done! You can now preview locally with 'bundle exec jekyll serve'"
