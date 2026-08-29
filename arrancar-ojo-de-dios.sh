#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
cd "$HOME/Proyectos/gods-eye-view"
echo "Arrancando Ojo de Dios en modo gratis/local..."
echo "Abre: http://localhost:4173"
echo "Nota: sin GOOGLE_MAPS_API_KEY usa OSM gratis; no tendrás Google 3D fotorealista."
npm run dev -- --host localhost --port 4173
