RabbitMQ with MQTT (Docker Compose)

This compose file starts RabbitMQ with the following plugins enabled:

- rabbitmq_management (HTTP management UI on port 15672)
- rabbitmq_mqtt (MQTT on port 1883)
- rabbitmq_web_mqtt (MQTT over WebSocket on port 15675)

Files:
- `docker-compose.yml` — starts a `rabbitmq:3.11-management` container with the plugins enabled.

Run (PowerShell):

from project root run:

```
 docker compose up -d
```

Check status:

```
 docker compose ps
```

Management UI:
- Open http://localhost:15672 and login with `guest` / `guest` (only for local/dev).

MQTT endpoints exposed by the container (local host):
- MQTT (plain TCP): tcp://localhost:1883
- MQTT over WebSocket: ws://localhost:15675/ws

Notes for the Angular app in this repo:
- `src/app/mqtt.service.ts` currently uses `wss://test.mosquitto.org:8081` as the default broker.
  To connect to this local RabbitMQ instance over WebSocket change the connect call to:

```
 // in src/app/app.ts or where you call connect()
 this.mqtt.connect('ws://localhost:15675/ws');
```

If you prefer secure WebSocket (wss) you'll need to provide certificates and run RabbitMQ with TLS.

Security reminder: The default `guest/guest` credentials are suitable for local development only. Please change credentials and secure access for any non-local deployment.
