# Ojo de Dios USB Cloud — arquitectura estilo película

Objetivo de Luis:

- La web vive en la nube.
- El USB funciona como llave privada.
- Quien conecta el USB puede abrir Ojo de Dios.
- Las claves/API no van en el USB ni en GitHub Pages.
- Nada de hacking: app privada + datos públicos/agregados + APIs legales.

## Arquitectura elegida

```text
USB de Luis
  └── contiene token privado + lanzador peliculero
        ↓ abre
GitHub Pages
  └── sirve la web estática de Ojo de Dios
        ↓ llama APIs con token
Cloudflare Worker
  └── comprueba token USB
  └── guarda secretos server-side: TOMTOM_API_KEY, futuras claves
  └── proxy seguro hacia TomTom / Overpass / futuras APIs
```

## Por qué no solo GitHub

GitHub Pages sirve archivos estáticos: HTML, JS, CSS, imágenes.
No ejecuta un servidor Node continuo como el Vite local.

Esta app usa muchas rutas `/api/...` para proteger claves y evitar CORS.
Por eso separamos:

- GitHub Pages: la pantalla/app.
- Cloudflare Worker: mini-servidor gratis para APIs y secretos.
- USB: llave de acceso.

## Qué se ha preparado en el proyecto

1. `src/cloudApiBase.js`

Permite que la misma app funcione así:

- Local: usa `/api/...` del servidor Vite local.
- Cloud: si existe `VITE_API_BASE_URL`, reescribe `/api/...` hacia Cloudflare Worker.

También lee `?igor_key=...` desde la URL del USB, guarda el token en `localStorage` y lo oculta de la barra del navegador.

2. `vite.config.js`

Añadido:

- `base: './'` para que el build sirva bien en GitHub Pages.
- `VITE_API_BASE_URL` para apuntar al Worker cloud.

3. `.github/workflows/deploy-pages.yml`

Workflow para publicar `dist/` en GitHub Pages.

4. `cloudflare-worker/ojo-worker.js`

Worker v1 con:

- bloqueo por `USB_ACCESS_TOKEN`,
- `/api/health`,
- `/api/tomtom/status`,
- `/api/tomtom/flow/{z}/{x}/{y}.pbf`,
- `/api/overpass` proxy con varios mirrors.

5. `scripts/crear-usb-ojo-cloud.sh`

Genera una carpeta USB con:

- `IGOR_USB_TOKEN.txt`,
- `config.env`,
- `ABRIR-OJO-DE-DIOS.sh`,
- `ABRIR-OJO-DE-DIOS.html`,
- `LEEME-LUIS.txt`.

## Pasos de despliegue real

### 1. Crear repo GitHub propio

Recomendado: repositorio nuevo de Luis, por ejemplo:

```bash
gh repo create ojo-de-dios-cloud --private --source . --push
```

Si GitHub Pages privado no estuviera disponible en tu cuenta, se puede hacer público sin secretos, porque las claves quedan en Cloudflare Worker.

### 2. Activar GitHub Pages

En GitHub:

`Settings → Pages → Source: GitHub Actions`

### 3. Desplegar Worker

```bash
cd cloudflare-worker
cp wrangler.toml.example wrangler.toml
npx wrangler login
npx wrangler secret put USB_ACCESS_TOKEN
npx wrangler secret put TOMTOM_API_KEY
npx wrangler deploy
```

El deploy devuelve una URL tipo:

```text
https://ojo-de-dios-api.TU_USUARIO.workers.dev
```

### 4. Guardar URL del Worker en GitHub

En el repo GitHub:

`Settings → Secrets and variables → Actions → Variables → New repository variable`

Nombre:

```text
VITE_API_BASE_URL
```

Valor:

```text
https://ojo-de-dios-api.TU_USUARIO.workers.dev
```

### 5. Crear llave USB

Cuando tengamos la URL de GitHub Pages:

```bash
./scripts/crear-usb-ojo-cloud.sh /run/media/$USER/IGOR_KEY https://TU_USUARIO.github.io/ojo-de-dios-cloud/
```

El script genera el token. Ese mismo token debe ir como secreto `USB_ACCESS_TOKEN` en Cloudflare Worker.

## Seguridad realista

Esto queda privado por token, pero hay que entenderlo bien:

- Si alguien copia el USB o copia el token, puede entrar.
- Si pasa eso, regeneramos token y cambiamos `USB_ACCESS_TOKEN` en Cloudflare.
- Las claves buenas como TomTom no van en el frontend.
- No meter `.env` en GitHub.
- No exponer claves en JavaScript público.

## Limitación v1

El Worker v1 cubre TomTom y Overpass, que son lo importante para coches/tráfico.
Otras capas `/api/...` pueden necesitar añadirse después una por una.
La web cargará, pero algunas capas avanzadas pueden quedar limitadas hasta portar su endpoint al Worker.

## Frase del sistema

```text
IGOR KEY ONLINE
SECURE CLOUD LINK ESTABLISHED
GOD'S EYE VIEW READY
```
