#!/usr/bin/env bash
set -euo pipefail

# Creates a cinematic limited USB launcher for the already-deployed GitHub Pages app.
# This version needs no Cloudflare account and stores no private API secrets.
# Usage:
#   ./scripts/crear-usb-ojo-limitado.sh /run/media/$USER/IGOR_KEY
# Optional URL override:
#   ./scripts/crear-usb-ojo-limitado.sh /run/media/$USER/IGOR_KEY https://lyux69.github.io/ojo-de-dios-cloud/

USB_DIR="${1:-}"
OJO_URL="${2:-https://lyux69.github.io/ojo-de-dios-cloud/}"

if [[ -z "$USB_DIR" ]]; then
  echo "Uso: $0 /ruta/del/usb [https://url-del-ojo-de-dios/]" >&2
  exit 1
fi

TARGET="$USB_DIR/OJO-DE-DIOS-USB-LIMITADO"
mkdir -p "$TARGET"
cd "$TARGET"

cat > config.env <<EOF
OJO_DE_DIOS_URL=$OJO_URL
OJO_DE_DIOS_MODE=LIMITADO_GITHUB_PAGES
EOF

cat > ABRIR-OJO-DE-DIOS.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.env"
URL="${OJO_DE_DIOS_URL}#v=2&l=t"
clear 2>/dev/null || true
echo "╔════════════════════════════════════════════╗"
echo "║             IGOR USB KEY                  ║"
echo "║        CLOUD LINK ESTABLISHED             ║"
echo "║      GOD'S EYE VIEW — LIMITED MODE        ║"
echo "╚════════════════════════════════════════════╝"
echo
echo "Abriendo Ojo de Dios desde GitHub Pages..."
echo "$OJO_DE_DIOS_URL"
echo
echo "Modo limitado: sin Cloudflare, algunas capas live/API pueden no funcionar."
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL"
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
<title>IGOR USB KEY — Ojo de Dios Limitado</title>
<style>
  :root{color-scheme:dark}
  body{margin:0;min-height:100vh;background:radial-gradient(circle at 50% 32%,#173c39 0,#061716 38%,#020404 72%,#000 100%);color:#79fff1;font-family:ui-monospace,SFMono-Regular,Consolas,monospace;display:grid;place-items:center;overflow:hidden}
  body:before{content:"";position:fixed;inset:0;background:linear-gradient(transparent 50%,#00ffe90d 50%);background-size:100% 4px;pointer-events:none;animation:scan 9s linear infinite}
  body:after{content:"";position:fixed;inset:-20%;background:conic-gradient(from 180deg,#00ffe900,#00ffe933,#00ffe900 18%);opacity:.28;animation:radar 6s linear infinite;filter:blur(1px)}
  .box{position:relative;z-index:1;border:1px solid #28ffe6aa;box-shadow:0 0 48px #00ffe055,inset 0 0 35px #00ffe01f;background:#001b1acc;padding:32px;max-width:780px;width:calc(100% - 52px);text-align:center;border-radius:12px}
  .badge{color:#061716;background:#79fff1;display:inline-block;padding:7px 12px;border-radius:999px;font-weight:900;letter-spacing:.12em;margin-bottom:18px}
  h1{font-size:clamp(30px,7vw,66px);line-height:1;margin:0;text-shadow:0 0 22px #79fff1;letter-spacing:.11em}
  h2{font-size:clamp(16px,3vw,24px);font-weight:500;color:#b8fff8;margin:14px 0 6px}
  p{font-size:16px;line-height:1.55;color:#cffff9}
  a{display:inline-block;margin-top:18px;padding:16px 24px;border-radius:8px;background:#79fff1;color:#001b18;text-decoration:none;font-weight:950;box-shadow:0 0 28px #79fff1;letter-spacing:.08em}
  .warn{margin-top:18px;color:#ffd36b;font-size:14px}
  @keyframes radar{to{transform:rotate(360deg)}}
  @keyframes scan{to{background-position-y:160px}}
</style>
<div class="box">
  <div class="badge">USB KEY DETECTED</div>
  <h1>IGOR KEY ONLINE</h1>
  <h2>GOD'S EYE VIEW READY</h2>
  <p>Esta llave abre la versión alojada en GitHub Pages.</p>
  <a href="$OJO_URL#v=2&l=t">ABRIR OJO DE DIOS</a>
  <p class="warn">Modo limitado: sin Cloudflare no hay servidor privado de APIs. Mapa y capas públicas/keyless sí; capas con secretos pueden estar limitadas.</p>
</div>
</html>
EOF

cat > LEEME-LUIS.txt <<EOF
OJO DE DIOS USB LIMITADO

Esto es la versión rápida sin Cloudflare.

Cómo usarlo:
1) Conecta el USB.
2) Abre ABRIR-OJO-DE-DIOS.html con doble clic.
3) O en Linux ejecuta ABRIR-OJO-DE-DIOS.sh.

URL que abre:
$OJO_URL

Qué funciona:
- Web alojada en GitHub Pages.
- Estética USB estilo película.
- Acceso desde PC/tablet/iPhone si abres la URL.
- No requiere crear cuenta Cloudflare ahora.

Límite importante:
- Esto NO es seguridad real por llave USB.
- GitHub Pages es público si alguien conoce la URL.
- Sin Cloudflare no podemos guardar secretos privados ni proteger APIs con token.
- Algunas capas live que dependan de /api o claves privadas pueden fallar.

Versión definitiva futura:
GitHub Pages + Cloudflare Worker + USB token.
EOF

echo "USB limitado preparado en: $TARGET"
echo "Abre: $TARGET/ABRIR-OJO-DE-DIOS.html"
