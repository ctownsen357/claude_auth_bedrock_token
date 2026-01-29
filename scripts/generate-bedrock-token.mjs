#!/usr/bin/env node

import { getTokenProvider } from '@aws/bedrock-token-generator';

try {
  const profile = process.env.AWS_PROFILE;
  const region = process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION || 'us-east-1';

  const provideToken = getTokenProvider({
    profile,
    region,
  });

  const token = await provideToken();
  process.stdout.write(token);
} catch (error) {
  process.stderr.write(`Error generating token: ${error.message}\n`);
  process.exit(1);
}
