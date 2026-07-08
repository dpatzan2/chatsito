# Chatsito Server

Backend del chat: Fastify + Postgres (Drizzle) + LiveKit.

## Correr en local

    docker compose up -d          # postgres (puerto 5435) + livekit
    cp .env.example .env          # editar JWT_SECRET
    npm install
    npm run dev                   # http://localhost:3000

Sin credenciales de Twilio en `.env`, el código OTP se imprime en la consola
del servidor (`[DEV SMS] ...`).

El front Flutter (`../CHAT`) se conecta a este server: ver su README para
correr la app y el smoke end-to-end. `GET /users/lookup?phone=` busca un
usuario por teléfono (para iniciar chats nuevos desde la app).

## Tests

    npm test                      # requiere Docker (Testcontainers)

## Protocolo WebSocket v1

Conexión: `ws://localhost:3000/ws` con el access JWT en el subprotocolo —
`new WebSocket(url, ['bearer', accessJWT])` (Dart: `WebSocket.connect(url, protocols: ['bearer', jwt])`).
El token nunca va en la URL (las URLs acaban en logs). Cierra con 4001 si es inválido.

Cliente→servidor: `{"v":1,"op":"...","seq":N,"d":{...}}` — todo op se responde con
`sys.ack {seq,...}` o `sys.error {seq,code,message}`.
Servidor→cliente: `{"v":1,"op":"...","ts":ms,"d":{...}}`.

| Op cliente | d | Respuesta / eventos |
|---|---|---|
| `sys.ping` | — | `sys.ack` |
| `msg.send` | `{conversationId \| channelId, type, content}` | `sys.ack {id}` + `msg.new` a los destinatarios (canal: miembros con `VIEW_CHANNEL`) |
| `msg.delete` | `{id}` | `sys.ack` + `msg.deleted {id, conversationId \| channelId}` |
| `typing.start` | `{conversationId}` | `sys.ack`; `typing {conversationId, userId}` al otro |
| `read.mark` | `{conversationId, messageId}` | `sys.ack` |
| `sys.resume` | `{targets:[{conversationId \| channelId, lastMsgId}]}` | `sys.ack` + `sys.resumed {targets:[{..., messages}]}` |
| `voice.join` | `{channelId}` | `sys.ack` + `voice.ready {channelId, token, url, members}` (token LiveKit, 10 min) |
| `voice.leave` | `{channelId}` | `sys.ack`; LiveKit confirma con webhook → `voice.state` |
| `voice.mute` | `{channelId, userId, muted}` | `sys.ack` + `voice.state` (requiere `VOICE_MUTE_MEMBERS`) |

Eventos de gestión de comunidades (servidor→cliente, a todos los miembros):
`community.updated/deleted`, `channel.created/updated/deleted`,
`role.created/updated/deleted`, `member.joined/left/updated`, `override.updated`.
`permissions`/`allow`/`deny` viajan como string decimal (bitfield BigInt).

Voz: el cliente conecta al SFU con el token de `voice.ready`
(`livekit_client` en Flutter). La ocupación viaja en `voice.state
{channelId, members:[{userId, muted}]}`, alimentada por los webhooks de
LiveKit (`POST /livekit/webhook`). Sin `VOICE_SPEAK` el token es
solo-escucha; *speaking* lo da el SDK de LiveKit directamente.

Tipos de mensaje y su `content`: `text {text}`, `doc {name, size}`, `sticker {sticker}`,
`image {}`, `video {}` (media real fuera de alcance por ahora).
