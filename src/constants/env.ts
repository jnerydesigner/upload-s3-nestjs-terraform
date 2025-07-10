import 'dotenv/config';

import { z } from 'zod';

export const envSchema = z.object({
  SERVER_PORT: z.coerce.number().default(3000),
  AWS_ACCESS_KEY_ID: z.string().min(1, 'AWS_ACCESS_KEY_ID is required'),
  AWS_SECRET_ACCESS_KEY: z.string().min(1, 'AWS_SECRET_ACCESS_KEY is required'),
  AWS_REGION: z.string().min(1, 'AWS_REGION is required'),
  AWS_BUCKET_NAME: z.string().min(1, 'AWS_BUCKET_NAME is required'),
  SSL_KEY: z.string(),
  SSL_CERT: z.string(),
});

const env = envSchema.parse(process.env);

export { env };
