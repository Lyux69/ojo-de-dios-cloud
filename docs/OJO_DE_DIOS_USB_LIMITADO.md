# Ojo de Dios USB limitado — sin Cloudflare

Esta es la versión rápida para seguir avanzando aunque Cloudflare no esté listo.

## Qué hace

El USB no ejecuta servidor. El USB actúa como una llave/lanzador visual.

```text
USB
  └── ABRIR-OJO-DE-DIOS.html
        ↓ abre
GitHub Pages
  └── https://lyux69.github.io/ojo-de-dios-cloud/
```

## Qué funciona

- La web ya vive en GitHub Pages.
- Puedes abrirla desde PC, tablet o iPhone con internet.
- El USB da la experiencia “película”: `IGOR KEY ONLINE`.
- No hace falta Cloudflare ahora.
- No hace falta Raspberry Pi.

## Límite importante

Esto no es seguridad real por USB.

Como GitHub Pages es público, alguien con la URL podría abrir la web.
El USB no puede ocultar de verdad una web pública.

También hay capas avanzadas que pueden estar limitadas porque no hay backend `/api`:

- claves privadas,
- TomTom protegido,
- algunos proxies,
- rutas que antes hacía Vite local,
- futuras APIs secretas.

Para seguridad real después volvemos a:

```text
GitHub Pages + Cloudflare Worker + USB token
```

## Crear el USB limitado

Conecta un USB. Si aparece montado como `/run/media/$USER/IGOR_KEY`, ejecuta:

```bash
cd ~/Proyectos/gods-eye-view
./scripts/crear-usb-ojo-limitado.sh /run/media/$USER/IGOR_KEY
```

Si el USB tiene otro nombre, cambia la ruta.

El script creará:

```text
OJO-DE-DIOS-USB-LIMITADO/
  ABRIR-OJO-DE-DIOS.html
  ABRIR-OJO-DE-DIOS.sh
  config.env
  LEEME-LUIS.txt
```

## Uso

En PC:

- doble clic en `ABRIR-OJO-DE-DIOS.html`, o
- ejecutar `ABRIR-OJO-DE-DIOS.sh`.

En iPhone/tablet:

- abre la URL de GitHub Pages directamente:

```text
https://lyux69.github.io/ojo-de-dios-cloud/
```

## Frase visual

```text
USB KEY DETECTED
IGOR KEY ONLINE
GOD'S EYE VIEW READY
```
