declare module 'ngx-mqtt' {
  import { ModuleWithProviders } from '@angular/core';
  import { Observable } from 'rxjs';

  export interface IMqttServiceOptions {
    hostname?: string;
    port?: number;
    path?: string;
    protocol?: string;
    username?: string;
    password?: string;
  }

  export const MqttModule: {
    forRoot(options: IMqttServiceOptions | any): ModuleWithProviders<any>;
  };

  export enum MqttConnectionState {
    CLOSED = 0,
    CONNECTING = 1,
    CONNECTED = 2,
    ERROR = 3,
  }

  export interface IMqttMessage {
    topic: string;
    payload: string | Uint8Array;
  }

  export class MqttService {
    state: Observable<MqttConnectionState>;
    client: any;
    observe(topic: string): Observable<IMqttMessage>;
    unsafePublish(topic: string, payload: string, options?: any): void;
  }

  export { MqttService as default };
}
