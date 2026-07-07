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
