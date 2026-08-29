#!/usr/bin/env bash
set -euo pipefail

# Creates the cinematic USB key folder for the cloud version.
# Usage:
#   ./scripts/crear-usb-ojo-cloud.sh /run/media/$USER/IGOR_KEY https://TU_USUARIO.github.io/ojo-de-dios/

USB_DIR="${1:-}"
OJO_URL="${2:-}"

if [[ -z "$USB_DIR" || -z "$OJO_URL" ]]; then
  echo "Uso: $0 /ruta/del/usb https://TU_USUARIO.github.io/ojo-de-dios/" >&2
  exit 1
fi

mkdir -p "$USB_DIR/OJO-DE-DIOS-USB"
cd "$USB_DIR/OJO-DE-DIOS-USB"

if [[ ! -f IGOR_USB_TOKEN.txt ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32 > IGOR_USB_TOKEN.txt
  else
    python3 - <<'PY' > IGOR_USB_TOKEN.txt
import secrets
print(secrets.token_hex(32))
PY
  fi
fi

TOKEN="$(tr -d '\r\n ' < IGOR_USB_TOKEN.txt)"
cat > config.env <<EOF
OJO_DE_DIOS_URL=$OJO_URL
IGOR_USB_TOKEN=$TOKEN
EOF
chmod 600 config.env IGOR_USB_TOKEN.txt 2>/dev/null || true

cat > ABRIR-OJO-DE-DIOS.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.env"
URL="${OJO_DE_DIOS_URL}?igor_key=${IGOR_USB_TOKEN}#v=2&l=t"
echo "╔══════════════════════════════════════╗"
echo "║        IGOR KEY ONLINE              ║"
echo "║        GOD'S EYE VIEW READY         ║"
echo "╚══════════════════════════════════════╝"
echo "Abriendo: $OJO_DE_DIOS_URL"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
  open "$URL"
else
  echo "Abre esta URL en tu navegador:"
  echo "$URL"
fi
EOF
chmod +x ABRIR-OJO-DE-DIOS.sh

cat > ABRIR-OJO-DE-DIOS.html <<EOF
<!doctype html>
<html lang="es">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>IGOR KEY — Ojo de Dios</title>
<style>
  body{margin:0;min-height:100vh;background:radial-gradient(circle at 50% 35%,#163b37,#020505 58%,#000);color:#6fffe9;font-family:ui-monospace,SFMono-Regular,Consolas,monospace;display:grid;place-items:center;overflow:hidden}
  .box{border:1px solid #27ffe5aa;box-shadow:0 0 40px #00ffe055,inset 0 0 30px #00ffe022;padding:34px;max-width:720px;width:calc(100% - 60px);background:#001c1aaa;text-align:center}
  h1{letter-spacing:.14em;font-size:clamp(26px,5vw,54px);margin:0 0 8px;text-shadow:0 0 20px #6fffe9}
  p{color:#b8fff6;font-size:18px;line-height:1.5}
  a{display:inline-block;margin-top:18px;color:#001b18;background:#6fffe9;padding:14px 22px;text-decoration:none;font-weight:900;border-radius:6px;box-shadow:0 0 24px #6fffe9}
  .scan{position:fixed;inset:0;background:linear-gradient(transparent 50%,#00ffe90b 50%);background-size:100% 4px;pointer-events:none}
</style>
<div class="scan"></div>
<div class="box">
  <h1>IGOR KEY ONLINE</h1>
  <p>Llave USB detectada. Sistema privado listo.</p>
  <p>Si no tienes esta llave, no tienes acceso al Ojo de Dios.</p>
  <a href="$OJO_URL?igor_key=$TOKEN#v=2&l=t">ABRIR OJO DE DIOS</a>
</div>
</html>
EOF

cat > LEEME-LUIS.txt <<EOF
OJO DE DIOS USB CLOUD

Esta llave abre la versión cloud privada.

1) Doble clic en ABRIR-OJO-DE-DIOS.html
   o ejecuta ABRIR-OJO-DE-DIOS.sh en Linux.

2) El token de esta llave está en:
   IGOR_USB_TOKEN.txt

3) Ese mismo token debe estar como secreto en Cloudflare Worker:
   USB_ACCESS_TOKEN

4) La URL pública va en config.env:
   OJO_DE_DIOS_URL=$OJO_URL

Importante:
- GitHub Pages solo sirve la web.
- Cloudflare Worker protege las APIs y las claves.
- El USB funciona como llave de entrada estilo película.
- Si alguien copia el token, habría que regenerarlo.
EOF

echo "USB preparado en: $USB_DIR/OJO-DE-DIOS-USB"
echo "Token generado/actual: $TOKEN"
echo "Pon este token en Cloudflare Worker como secret USB_ACCESS_TOKEN."
