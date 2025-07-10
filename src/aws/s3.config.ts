import { env } from '@app/constants/env';
import { Injectable } from '@nestjs/common';

@Injectable()
export class S3ConfigService {
  getS3Config() {
    return {
      accessKeyId: env.AWS_ACCESS_KEY_ID,
      secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
      region: env.AWS_REGION,
      bucketName: env.AWS_BUCKET_NAME,
    };
  }
}
