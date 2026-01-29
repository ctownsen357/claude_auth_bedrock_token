#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Prompt for AWS profile (default: mfauser)
echo "AWS profile [mfauser]: " >&2
read -r AWS_PROFILE_INPUT
PROFILE="${AWS_PROFILE_INPUT:-mfauser}"

echo "" >&2
echo "Starting SSO login for profile: $PROFILE" >&2
echo "" >&2

# Create a temp file to capture output
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Run SSO login, tee output to temp file while displaying to stderr
# Use a background process to extract and re-display the URL
{
  # Wait a moment for the URL to be written
  sleep 2
  # Extract URL from captured output
  if [ -f "$TMPFILE" ]; then
    URL=$(cat "$TMPFILE" | tr ' ' '\n' | grep '^https://' | head -1)
    if [ -n "$URL" ]; then
      # Write URL to a file for easy access
      echo "$URL" > /tmp/sso-login-url.txt

      # Try to copy to clipboard (macOS)
      if command -v pbcopy &>/dev/null; then
        echo "$URL" | pbcopy
        echo "" >&2
        echo "========================================" >&2
        echo "URL COPIED TO CLIPBOARD!" >&2
        echo "Just paste (Cmd+V) in your browser." >&2
        echo "========================================" >&2
      else
        echo "" >&2
        echo "========================================" >&2
        echo "URL saved to /tmp/sso-login-url.txt" >&2
        echo "Run: cat /tmp/sso-login-url.txt" >&2
        echo "========================================" >&2
      fi
      echo "" >&2
    fi
  fi
} &

# Run the actual SSO login, capturing output while showing it
aws sso login --profile "$PROFILE" --no-browser 2>&1 | tee "$TMPFILE" >&2

# Wait for background job
wait

echo "" >&2
echo "SSO login complete. Generating Bedrock bearer token..." >&2

# Generate the token using the Node.js script
TOKEN=$(AWS_PROFILE="$PROFILE" node "$PROJECT_DIR/scripts/generate-bedrock-token.mjs")

if [ -z "$TOKEN" ]; then
  echo "Error: Failed to generate token" >&2
  exit 1
fi

echo "" >&2
echo "Token generated successfully!" >&2
echo "The following exports will be set in your shell:" >&2
echo "  - AWS_PROFILE=$PROFILE" >&2
echo "  - AWS_BEARER_TOKEN_BEDROCK=<token>" >&2
echo "" >&2

# Print export commands to stdout (this is what gets eval'd)
echo "export AWS_PROFILE='$PROFILE'"
echo "export AWS_BEARER_TOKEN_BEDROCK='$TOKEN'"
