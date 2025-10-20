import {
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZoneChangeDetection,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { IMqttServiceOptions, MqttModule } from 'ngx-mqtt';

import { routes } from './app.routes';

export const MQTT_SERVICE_OPTIONS: IMqttServiceOptions = {
  // Use RabbitMQ Web MQTT plugin default websocket endpoint for local development
  hostname: 'localhost',
  port: 15675,
  path: '/ws',
  protocol: 'ws',
};

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    // Spread the providers returned by MqttModule.forRoot(...) so ApplicationConfig.providers contains Provider entries
    ...(MqttModule.forRoot(MQTT_SERVICE_OPTIONS).providers ?? ([] as any)),
  ],
};
