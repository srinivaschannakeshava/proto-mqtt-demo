Python MQTT publisher
======================

This small example publishes random SimpleRequest protobuf messages to an MQTT broker.

Setup
-----

1. Create a virtual environment and install dependencies:

```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1; pip install -r requirements.txt
```

2. Start the RabbitMQ docker compose (if not running):

```powershell
# from project root
cd ..; docker compose up -d
```

Run
---

```powershell
python publish.py --broker ws://localhost:15675 --topic mqtt/proto/demo --interval 1.0
```

Notes
-----

- This example uses a hand-written minimal `simple_pb2.py` for brevity. For production, generate Python protobuf code with `protoc --python_out`.
- The publisher uses paho-mqtt and sends protobuf-serialized binary payloads.
