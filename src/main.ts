/* eslint-disable @typescript-eslint/no-floating-promises */
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { Logger } from '@nestjs/common';
import * as https from 'https';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  app.enableCors({
    origin: '*',
  });

  const logger = new Logger('Bootstrap');

  // Recupera e ajusta as variáveis de ambiente
  const sslKey = config.get<string>('SSL_KEY');
  const sslCert = config.get<string>('SSL_CERT');

  if (!sslKey || !sslCert) {
    logger.error('SSL_KEY or SSL_CERT is missing. HTTPS server cannot start.');
    process.exit(1);
  }

  const httpsOptions = {
    key: sslKey.replace(/\\n/g, '\n'),
    cert: sslCert.replace(/\\n/g, '\n'),
  };

  const port = config.get<number>('SERVER_PORT') || 3000;

  const server = https.createServer(
    httpsOptions,
    app.getHttpAdapter().getInstance(),
  );

  await app.init();

  server.listen(port, () => {
    logger.log(`Application is running on: https://localhost:${port}`);
  });
}

bootstrap();
