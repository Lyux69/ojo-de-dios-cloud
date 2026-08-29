#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
APP_DIR="$HOME/Proyectos/gods-eye-view"
URL="http://localhost:4173/"
LOG_DIR="$HOME/.local/state/ojo-de-dios"
CHROME_PROFILE="$HOME/.local/share/ojo-de-dios-chrome"
mkdir -p "$LOG_DIR" "$CHROME_PROFILE"
cd "$APP_DIR"

if ! curl -fsS "$URL" >/dev/null 2>&1; then
  echo "Arrancando servidor local de Ojo de Dios..."
  nohup npm run dev -- --host localhost --port 4173 > "$LOG_DIR/vite.log" 2>&1 &
  echo $! > "$LOG_DIR/vite.pid"

  for i in {1..40}; do
    if curl -fsS "$URL" >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done
fi

if ! curl -fsS "$URL" >/dev/null 2>&1; then
  echo "No he podido arrancar el servidor. Mira el log: $LOG_DIR/vite.log"
  exit 1
fi

echo "Abriendo Ojo de Dios gratis con WebGL por software..."
echo "$URL"

google-chrome \
  --user-data-dir="$CHROME_PROFILE" \
  --no-first-run \
  --ignore-gpu-blocklist \
  --enable-webgl \
  --enable-unsafe-swiftshader \
  --new-window "$URL" \
  > "$LOG_DIR/chrome.log" 2>&1 &

echo "Listo. Si quieres cerrar el servidor luego: kill $(cat "$LOG_DIR/vite.pid" 2>/dev/null || true)"
