"""Simple MQTT publisher that sends random SimpleRequest messages.

Usage:
  python publish.py --broker ws://localhost:15675 --topic mqtt/proto/demo --interval 1.0

This script depends on paho-mqtt and protobuf (see requirements.txt).
"""

import argparse
import logging
import random
import time
import sys

import paho.mqtt.client as mqtt
import simple_pb2


def build_message(name: str, id: int) -> bytes:
    msg = simple_pb2.SimpleRequest()
    msg.name = name
    msg.id = id
    return msg.SerializeToString()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--broker', default='mqtt://localhost:1883', help='MQTT broker URL (mqtt://host:port or ws://host:port)')
    parser.add_argument('--topic', default='mqtt/proto/demo')
    parser.add_argument('--interval', type=float, default=1.0)
    parser.add_argument('--log-level', default='INFO', help='Logging level (DEBUG, INFO, WARNING, ERROR)')
    args = parser.parse_args()

    # configure logging
    numeric_level = getattr(logging, args.log_level.upper(), None)
    if not isinstance(numeric_level, int):
        print(f'Invalid log level: {args.log_level}', file=sys.stderr)
        numeric_level = logging.INFO
    logging.basicConfig(level=numeric_level, format='%(asctime)s %(levelname)s %(message)s')
    logger = logging.getLogger('publisher')
    logger.info('Starting publisher')

    # paho-mqtt expects broker host+port; accept schemes:
    #  - ws:// or wss:// -> use websockets transport
    #  - mqtt:// or tcp:// or no scheme -> normal MQTT over TCP
    broker = args.broker
    use_websocket = False
    if broker.startswith('ws://') or broker.startswith('wss://'):
        use_websocket = True
        scheme_removed = broker.split('://', 1)[1]
        host_port = scheme_removed
    elif broker.startswith('mqtt://') or broker.startswith('tcp://'):
        scheme_removed = broker.split('://', 1)[1]
        host_port = scheme_removed
    else:
        # assume host[:port]
        host_port = broker

    if ':' in host_port:
        host, port = host_port.split(':', 1)
        port = int(port)
    else:
        host = host_port
        port = 1883

    # Create client with correct transport for websockets when requested
    if use_websocket:
        client = mqtt.Client(transport='websockets')
        # common websocket path used by some brokers (adjustable if needed)
        client.ws_set_options(path='/ws')
    else:
        client = mqtt.Client()

    def on_connect(c, userdata, flags, rc):
        if rc == 0:
            logger.info('Connected to %s (rc=%s)', args.broker, rc)
        else:
            logger.error('Connection to %s failed (rc=%s)', args.broker, rc)

    def on_disconnect(c, userdata, rc):
        logger.info('Disconnected from broker (rc=%s)', rc)

    def on_publish(c, userdata, mid):
        logger.debug('Publish acknowledged (mid=%s)', mid)

    def on_log(c, userdata, level, buf):
        # Mirror paho logs to our logger at DEBUG level
        logger.debug('paho-mqtt: %s', buf)

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_publish = on_publish
    client.on_log = on_log

    logger.info('Connecting to %s:%s (use_websocket=%s)', host, port, use_websocket)
    try:
        client.connect(host, port)
    except Exception as e:
        logger.exception('Failed to connect to broker: %s', e)
        raise
    client.loop_start()

    try:
        while True:
            name = random.choice(['alice', 'bob', 'carol', 'dave'])
            idv = random.randint(0, 1000)
            payload = build_message(name, idv)
            # publish as binary
            try:
                result = client.publish(args.topic, payload)
                # paho publish returns (rc, mid) or MQTTMessageInfo depending on version
                logger.info('Published to %s: name=%s id=%s (len=%d) result=%s', args.topic, name, idv, len(payload), result)
            except Exception:
                logger.exception('Failed to publish message to %s', args.topic)

            time.sleep(args.interval)
    except KeyboardInterrupt:
        logger.info('Stopping publisher (KeyboardInterrupt)')
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == '__main__':
    main()
