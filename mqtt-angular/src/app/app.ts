import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MqttService } from './mqtt.service';
import { SimpleRequest } from './proto/simple';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected readonly title = signal('mqtt-angular');

  protected readonly connectionState = signal<
    'disconnected' | 'connecting' | 'connected' | 'error'
  >('disconnected');
  protected readonly lastMessageProto = signal<string | null>(null);
  protected readonly lastMessageConverted = signal<string | null>(null);

  private mqtt: MqttService;
  protected nameInput = signal('');
  protected idInput = signal(0);
  constructor(mqtt: MqttService) {
    this.mqtt = mqtt;
    // connect to the broker and subscribe to a demo topic
    this.mqtt.connectionState.subscribe((s) => this.connectionState.set(s));
    this.mqtt.messages.subscribe((m) => {
      if (!m) {
        this.lastMessageProto.set(null);
        this.lastMessageConverted.set(null);
        return;
      }

      this.lastMessageProto.set(`${m.topic}: ${m.payload}`);

      try {
        // const decoded = decodeSimpleRequest(m.payload);
        const decoded = SimpleRequest.decode(m.payload);
        this.lastMessageConverted.set(
          typeof decoded === 'string' ? decoded : JSON.stringify(decoded)
        );
      } catch (err) {
        this.lastMessageConverted.set(null);
        console.error('Failed to decode proto message', err);
      }
    });
    this.mqtt.connect();
    this.mqtt.subscribe('mqtt/proto/demo');
  }

  protected publishSimple() {
    // Build a lightweight protobuf Type matching SimpleRequest { string name = 1; int32 id = 2; }

    const message = {
      name: this.nameInput(),
      id: Number(this.idInput()),
    };

    // encode the plain object using the generated encoder
    const encoded = SimpleRequest.encode(message).finish();

    // publish as binary to the topic
    this.mqtt.publish('mqtt/proto/demo', encoded);
  }

  protected disconnect() {
    this.mqtt.disconnect();
  }
}
