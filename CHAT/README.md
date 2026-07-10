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
(`[DEV SMS] ...`). La sesión persiste entre reinicios (shared_preferences);
solo se vuelve a pedir el código si el refresh token caduca.

- **Idiomas**: es, en, pt, fr — se usa el del sistema (fallback: español).
  Añadir uno = un archivo `lib/l10n/intl_<código>.arb` + su entrada en
  `wireStrings` (wire.dart).
- **Registro**: el prefijo telefónico se elige de una lista de países
  (preseleccionado por la región del sistema); el número viaja como
  `prefijo+dígitos`.
- **Nuevo chat**: botón ✏️ → *Nuevo chat* → teléfono del otro usuario
  (con prefijo de país, solo dígitos).
- **Comunidades**: ✏️ → *Nueva comunidad*; se invita con el código que genera
  el botón 👤+ del grupo, y se entra con *Unirme con código*.
- **No leídos**: contador por conversación y por comunidad en la lista de
  chats, y badge por canal dentro del grupo (`read.mark` al abrirlos).
- **Roles**: el botón 🛡 del grupo (visible con permiso *Gestionar roles*)
  lista los roles; se crean/editan con color, permisos y miembros.
- **Voz**: tocar un canal de voz conecta al SFU de LiveKit (mic real);
  el mute propio apaga el micrófono, la ocupación llega por `voice.state`.
- **Media**: 📎 → *Galería* o *Documento* sube el archivo al server (límite
  25 MB) y lo manda al hilo; las imágenes se ven inline con visor a pantalla
  completa y los docs se abren al tocarlos.
- **Miembros**: botón 👥 del grupo (o columna fija en ventanas anchas) muestra
  los miembros agrupados por rol con presencia online/offline en vivo.
- **Detalles del chat**: tocar el header abre el perfil del contacto (1:1,
  teléfono y media reales) o el detalle del canal (miembros, invitar, salir
  de la comunidad).
- **Ajustes**: editar nombre y foto de perfil, cerrar sesión y eliminar la
  cuenta; el resto de secciones sigue siendo visual.
- **Crear canales**: botón + junto a los títulos de canales del grupo
  (visible con permiso *Gestionar canales*), texto o voz.

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
