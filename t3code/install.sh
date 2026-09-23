#!/usr/bin/env bash
# Install or upgrade T3 Code from its latest GitHub release.
set -euo pipefail

REPO="pingdotgg/t3code"
APP_DIR="$HOME/Applications"
APP_LINK="$APP_DIR/t3code.AppImage"
APPS_DIR="$HOME/.local/share/applications"
ICON_PATH="$HOME/.local/share/icons/t3code.png"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

release="$(curl -fsSL "https://github.com/$REPO/releases/latest/download/latest-linux.yml")"
version="$(sed -n 's/^version: //p' <<<"$release")"
asset="$(sed -n 's/^path: //p' <<<"$release")"
expected_sha512="$(sed -n 's/^sha512: //p' <<<"$release")"

if [[ -z "$version" || -z "$asset" || -z "$expected_sha512" ]]; then
  echo "could not parse latest-linux.yml for $REPO" >&2
  exit 1
fi

mkdir -p "$APP_DIR" "$APPS_DIR" "$(dirname "$ICON_PATH")"

appimage="$APP_DIR/$asset"
if [[ ! -f "$appimage" ]]; then
  echo "downloading T3 Code $version"
  curl -fL --progress-bar -o "$appimage" "https://github.com/$REPO/releases/download/v$version/$asset"
fi

actual_sha512="$(openssl dgst -sha512 -binary "$appimage" | openssl base64 -A)"
if [[ "$actual_sha512" != "$expected_sha512" ]]; then
  echo "sha512 mismatch for $appimage" >&2
  rm -f "$appimage"
  exit 1
fi

chmod +x "$appimage"
ln -sfn "$asset" "$APP_LINK"

# The AppImage carries the icon, but extracting it needs the same FUSE workaround.
if [[ ! -f "$ICON_PATH" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  (cd "$tmp" && "$appimage" --appimage-extract 'usr/share/icons/hicolor/512x512/apps/t3code.png' >/dev/null 2>&1) || true
  src="$tmp/squashfs-root/usr/share/icons/hicolor/512x512/apps/t3code.png"
  if [[ -f "$src" ]]; then
    install -Dm644 "$src" "$ICON_PATH"
  fi
fi

render() {
  sed -e "s|__T3_APPIMAGE__|$APP_LINK|g" -e "s|__T3_ICON__|$ICON_PATH|g" "$1"
}

render "$SRC_DIR/t3code.desktop" > "$APPS_DIR/t3code.desktop"
render "$SRC_DIR/t3code-url-handler.desktop" > "$APPS_DIR/t3code-url-handler.desktop"
update-desktop-database "$APPS_DIR" 2>/dev/null || true

echo "installed T3 Code $version -> $appimage"
