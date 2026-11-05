#!/usr/bin/env bash
# Usage: ./rebrand.sh /path/to/navidrome-source  "Prietify"
set -euo pipefail
SRC="$1"; NAME="${2:-Prietify}"; KIT="$(cd "$(dirname "$0")" && pwd)/assets"
cd "$SRC/ui"

# 1. Icons (favicons, PWA, apple, tiles, login logo)
for f in "$KIT"/*.png "$KIT"/favicon.ico; do
  b=$(basename "$f")
  case "$b" in
    login-icon.png) cp "$f" src/icons/android-icon-192x192.png ;;
    prietify-logo-wide.png) ;;
    *) cp "$f" "public/$b" ;;
  esac
done

# 2. Text: browser tab, page header, player title, PWA manifest, about dialog, i18n
sed -i "s/<title>Navidrome<\/title>/<title>$NAME<\/title>/; s/content=\"Navidrome Music Server/content=\"$NAME Music Server/; s/og:site_name\" content=\"Navidrome\"/og:site_name\" content=\"$NAME\"/" index.html
sed -i "s/Navidrome/$NAME/g" src/common/Title.jsx src/audioplayer/Player.jsx src/personal/Personal.jsx
sed -i "s/^\( *\)Navidrome\$/\1$NAME/" src/layout/Login.jsx
sed -i "s/name: 'Navidrome'/name: '$NAME'/; s/short_name: 'Navidrome'/short_name: '$NAME'/; s/'Navidrome, an open source/'$NAME, an open source/" vite.config.js
sed -i "s/Thanks for installing Navidrome!/Thanks for installing $NAME!/; s/\"title\": \"Navidrome Hotkeys\"/\"title\": \"$NAME Hotkeys\"/" src/i18n/en.json

# 3. Login: point the name link away from navidrome.org (remove link behaviour)
python3 - "$NAME" <<'PY'
import re,sys
p='src/layout/Login.jsx'; s=open(p).read()
s=s.replace('href="https://www.navidrome.org"','href="#"')
open(p,'w').write(s)
PY
echo "Rebrand applied to $SRC as '$NAME'"
