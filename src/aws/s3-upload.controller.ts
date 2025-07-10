import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { S3UploadService } from './s3-upload.service';

@Controller()
export class S3UploadController {
  constructor(private readonly s3UploadService: S3UploadService) {}
  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  uploadFile(@UploadedFile() file: Express.Multer.File) {
    return this.s3UploadService.uploadFile(file);
  }
}
