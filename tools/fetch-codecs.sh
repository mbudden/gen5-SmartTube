#!/bin/bash
# Download the media.codecs package (gen5-codec-patch) pinned in smarttube.conf
# and check it against the pinned SHA-256. It goes on the one-tap USB stick.
# usage: tools/fetch-codecs.sh       Prints the path of the verified zip (under .cache/codecs/).
set -euo pipefail

HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/smarttube.conf"
[ -n "${SMARTTUBE_CONF:-}" ] && . "$SMARTTUBE_CONF"
OUT=$HERE/.cache/codecs
mkdir -p "$OUT"

name=media.codecs-$CODECS_VERSION.zip
zip=$OUT/$name
url=https://github.com/$CODECS_REPO/releases/download/v$CODECS_VERSION/$name
sum() { shasum -a 256 "$1" | cut -d' ' -f1; }

if [ ! -f "$zip" ] || [ "$(sum "$zip")" != "$CODECS_ZIP_SHA256" ]; then
    echo "downloading $url" >&2
    curl -fL --progress-bar -o "$zip.part" "$url"
    mv "$zip.part" "$zip"
fi
got=$(sum "$zip")
[ "$got" = "$CODECS_ZIP_SHA256" ] || { echo "SHA-256 mismatch for $name: got $got, expected $CODECS_ZIP_SHA256" >&2; rm -f "$zip"; exit 1; }
echo "verified $name (sha256 $got)" >&2
echo "$zip"
