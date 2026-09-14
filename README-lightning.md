# Entorno Lightning local

El Compose levanta exactamente los cuatro servicios solicitados —Bitcoin Core
en `regtest`, LND, Mostro y Ride The Lightning (RTL)— en la red Docker común
que Compose crea automáticamente. Mostro usa el relay Nostr público definido
en su archivo de configuración.

## Publicar en Docker Hub

Después de `docker login`, ejecutar en PowerShell:

```powershell
.\docker-publish.ps1 -DockerHubUser TU_USUARIO -Version 1.0.0 -BitcoinVersion 31.1
```

Esto publica la misma imagen como `TU_USUARIO/bitcoin-core:1.0.0` y
`TU_USUARIO/bitcoin-core:latest`.

Repositorio: <https://hub.docker.com/r/TU_USUARIO/bitcoin-core>

## Desplegar

Copiar `.env.example` como `.env`, cambiar la contraseña RPC y reemplazar la
clave `nsec_privkey` de `mostro/settings.toml` por una clave de pruebas válida.

```powershell
docker compose up -d --build
docker compose ps
```

RTL queda disponible en <http://localhost:3000>. Para crear la wallet de LND:

```powershell
docker exec -it lnd-regtest lncli --network=regtest create
```

Tras crearla, si Mostro o RTL arrancaron antes de que existieran los archivos
de autenticación, ejecutar `docker compose restart mostro rtl`.

Detener: `docker compose down`. Borrar datos de regtest: `docker compose down -v`.

Verificación útil: `docker compose logs -f bitcoin lnd mostro rtl`. LND debe
mostrar conexión con `bitcoin:18443`; RTL debe abrirse en
<http://localhost:3000> y mostrar el nodo LND.
