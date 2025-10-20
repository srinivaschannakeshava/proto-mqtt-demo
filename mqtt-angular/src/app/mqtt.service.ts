import { Injectable } from '@angular/core';
import { IMqttMessage, MqttConnectionState, MqttService as NgxMqttService } from 'ngx-mqtt';
import { Observable, Subject } from 'rxjs';

export type ConnectionState = 'disconnected' | 'connecting' | 'connected' | 'error';

@Injectable({ providedIn: 'root' })
export class MqttService {
  private status$ = new Subject<ConnectionState>();
  private lastMessage$ = new Subject<{ topic: string; payload: Uint8Array }>();

  constructor(private ngx: NgxMqttService) {
    this.ngx.state.subscribe((s: MqttConnectionState) => {
      const state: ConnectionState =
        s === MqttConnectionState.CLOSED
          ? 'disconnected'
          : s === MqttConnectionState.CONNECTING
          ? 'connecting'
          : s === MqttConnectionState.CONNECTED
          ? 'connected'
          : 'error';
      this.status$.next(state);
    });
  }

  get connectionState(): Observable<ConnectionState> {
    return this.status$.asObservable();
  }

  get messages(): Observable<{ topic: string; payload: Uint8Array }> {
    return this.lastMessage$.asObservable();
  }

  connect(): void {
    // ngx-mqtt connects using provided config; no-op here
  }

  subscribe(topic: string): void {
    this.ngx.observe(topic).subscribe((msg: IMqttMessage) => {
      const payload =
        typeof msg.payload === 'string'
          ? new TextEncoder().encode(msg.payload)
          : (msg.payload as Uint8Array);
      this.lastMessage$.next({ topic: msg.topic, payload });
    });
  }

  publish(topic: string, payload: string | Uint8Array): void {
    if (typeof payload === 'string') {
      this.ngx.unsafePublish(topic, payload, { qos: 0, retain: false });
    } else {
      // publish binary via underlying client
      try {
        this.ngx.client.publish(topic, payload as any, { qos: 0, retain: false });
      } catch (e) {
        // fallback: base64 string
        const b64 = btoa(String.fromCharCode(...Array.from(payload)));
        this.ngx.unsafePublish(topic, b64, { qos: 0, retain: false });
      }
    }
  }

  disconnect(): void {
    try {
      this.ngx.client.end(true);
    } catch {}
  }
}
