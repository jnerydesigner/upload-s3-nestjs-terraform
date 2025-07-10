import { Injectable } from '@nestjs/common';

@Injectable()
export class S3ConfigService {
  getS3Config() {
    return {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION,
      bucketName: process.env.AWS_BUCKET_NAME,
    };
  }
}
