import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { S3UploadModule } from './aws/s3-upload.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
    }),
    S3UploadModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
