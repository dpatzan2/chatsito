# Chatsito Server

Backend del chat: Fastify + Postgres (Drizzle) + LiveKit.

## Correr en local

    docker compose up -d          # postgres (puerto 5435) + livekit
    cp .env.example .env          # editar JWT_SECRET
    npm install
    npm run dev                   # http://localhost:3000

Sin credenciales de Twilio en `.env`, el código OTP se imprime en la consola
del servidor (`[DEV SMS] ...`).

## Tests

    npm test                      # requiere Docker (Testcontainers)

## Protocolo WebSocket v1

Conexión: `ws://localhost:3000/ws?token=<accessJWT>` (cierra con 4001 si el token es inválido).

Cliente→servidor: `{"v":1,"op":"...","seq":N,"d":{...}}` — todo op se responde con
`sys.ack {seq,...}` o `sys.error {seq,code,message}`.
Servidor→cliente: `{"v":1,"op":"...","ts":ms,"d":{...}}`.

| Op cliente | d | Respuesta / eventos |
|---|---|---|
| `sys.ping` | — | `sys.ack` |
| `msg.send` | `{conversationId, type, content}` | `sys.ack {id}` + `msg.new` a ambos miembros |
| `msg.delete` | `{id}` | `sys.ack` + `msg.deleted {id, conversationId}` |
| `typing.start` | `{conversationId}` | `sys.ack`; `typing {conversationId, userId}` al otro |
| `read.mark` | `{conversationId, messageId}` | `sys.ack` |
| `sys.resume` | `{targets:[{conversationId, lastMsgId}]}` | `sys.ack` + `sys.resumed {targets:[{conversationId, messages}]}` |

Tipos de mensaje y su `content`: `text {text}`, `doc {name, size}`, `sticker {sticker}`,
`image {}`, `video {}` (media real fuera de alcance por ahora).
