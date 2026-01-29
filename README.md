# Bedrock Token Tools

Utilities for refreshing AWS Bedrock short-term bearer tokens used with `AWS_BEARER_TOKEN_BEDROCK`.

## Setup

```bash
npm install
```

## Usage

To refresh your Bedrock bearer token and set it in your current shell session:

```bash
eval "$(./scripts/bedrock-token-refresh.sh)"
```

Or alternatively:

```bash
source <(./scripts/bedrock-token-refresh.sh)
```

### What happens

1. You'll be prompted for an AWS profile name (default: `mfauser`)
2. The AWS CLI runs `aws sso login --profile <PROFILE> --no-browser`
3. The authorization URL is automatically copied to your clipboard (macOS)
4. Open the URL in an incognito browser and complete the SSO flow
5. Once SSO login completes, a Bedrock bearer token is generated
6. The following environment variables are set in your shell:
   - `AWS_PROFILE` - the profile you selected
   - `AWS_BEARER_TOKEN_BEDROCK` - the generated bearer token

### Force refresh

To force a token refresh, simply run the command again. This will re-authenticate via SSO and generate a new token.

## Claude Code Skill

You can install this as a Claude Code skill to invoke it from any directory with `/bedrock-token`.

### Installation

1. Clone this repo and run `npm install`

2. Create the skill directory:
   ```bash
   mkdir -p ~/.claude/skills/bedrock-token
   ```

3. Create `~/.claude/skills/bedrock-token/SKILL.md`:
   ```markdown
   ---
   name: bedrock-token
   description: Refresh AWS Bedrock bearer token via SSO login. Use when authentication fails or token expires.
   ---

   # Bedrock Token Refresh

   Run the token refresh script:

   ```bash
   ~/projects/claude_auth_bedrock_token/scripts/bedrock-token-refresh.sh
   ```

   After completion, set environment variables with:

   ```bash
   eval "$(~/projects/claude_auth_bedrock_token/scripts/bedrock-token-refresh.sh)"
   ```
   ```

4. Update the path in `SKILL.md` to match where you cloned this repo

5. Restart Claude Code

### Using the skill

From any Claude Code session, type:
```
/bedrock-token
```

## Scripts

- `scripts/bedrock-token-refresh.sh` - Interactive script that handles the full flow
- `scripts/generate-bedrock-token.mjs` - Node.js script that generates just the token (used internally)

You can also generate a token directly (after SSO login):

```bash
AWS_PROFILE=mfauser npm run bedrock:token
```
