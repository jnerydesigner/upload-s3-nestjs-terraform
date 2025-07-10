import { S3UploadService } from './s3-upload.service';
import { S3UploadController } from './s3-upload.controller';
import { Module } from '@nestjs/common';
import { S3ConfigService } from './s3.config';

@Module({
  imports: [],
  controllers: [S3UploadController],
  providers: [S3UploadService, S3ConfigService],
})
export class S3UploadModule {}
