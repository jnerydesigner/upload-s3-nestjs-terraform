import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { S3ConfigService } from './s3.config';
import { randomUUID } from 'node:crypto';

@Injectable()
export class S3UploadService {
  private readonly s3Client: S3Client;
  private readonly bucketName: string;
  private readonly region: string;

  constructor(private readonly s3Config: S3ConfigService) {
    const { accessKeyId, secretAccessKey, region, bucketName } =
      this.s3Config.getS3Config();

    if (!bucketName || !region) {
      throw new Error(
        'S3 configuration is missing required bucketName or region.',
      );
    }
    if (!accessKeyId || !secretAccessKey) {
      throw new Error(
        'S3 configuration is missing required accessKeyId or secretAccessKey.',
      );
    }
    this.bucketName = bucketName;
    this.region = region;
    this.s3Client = new S3Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });
  }

  async uploadFile(file: Express.Multer.File): Promise<{ url: string }> {
    const fileExtension = file.originalname.split('.').pop();
    const uniqueFileName = `${randomUUID()}-${Date.now()}.${fileExtension}`;
    const params = {
      Bucket: this.bucketName,
      Key: uniqueFileName,
      Body: file.buffer,
      ContentType: file.mimetype,
    };

    try {
      const command = new PutObjectCommand(params);
      await this.s3Client.send(command);

      return {
        url: `https://${this.bucketName}.s3.${this.region}.amazonaws.com/${uniqueFileName}`,
      };
    } catch (error) {
      console.error('S3 Upload Error:', error);
      throw new InternalServerErrorException('Error uploading file to S3');
    }
  }
}
