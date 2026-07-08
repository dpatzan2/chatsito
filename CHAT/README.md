# chatsito (app Flutter)

Front del chat, conectado al backend de `../server`.

## Correr contra el backend

```sh
# 1. backend (desde ../server)
docker compose up -d        # postgres (5435) + livekit (7880)
npm run dev                 # http://localhost:3000

# 2. app
flutter run                 # escritorio / iOS; usa http://localhost:3000
flutter run --dart-define=API_URL=http://10.0.2.2:3000   # emulador Android
```

Sin Twilio configurado, el código OTP sale en la consola del server
(`[DEV SMS] ...`). Los tokens viven solo en memoria: al reiniciar la app
se vuelve a pedir el código.

- **Nuevo chat**: botón ✏️ → *Nuevo chat* → teléfono del otro usuario.
- **Comunidades**: ✏️ → *Nueva comunidad*; se invita con el código que genera
  el botón 👤+ del grupo, y se entra con *Unirme con código*.
- **Voz**: tocar un canal de voz conecta al SFU de LiveKit (mic real);
  el mute propio apaga el micrófono, la ocupación llega por `voice.state`.

## Smoke end-to-end

Con el backend corriendo (y su log en un archivo):

```sh
dart run tool/smoke.dart /ruta/al/server.log
```

Recorre OTP → mensajes 1:1 → comunidad + invitación → canal → token de voz
usando los mismos `ApiClient`/`WsClient` de la app.

## Arquitectura

- `lib/domain/` modelos + interfaces de repositorio (sin red).
- `lib/data/api/` clientes (`api_client.dart`, `ws_client.dart`, mapeo `wire.dart`,
  voz `livekit_call.dart`) y `lib/data/api_*.dart` repos reales.
- `lib/data/in_memory_*.dart` fakes para tests de controladores.
- `lib/features/` pantallas y controladores (Provider).

## Tests

```sh
flutter test
```
