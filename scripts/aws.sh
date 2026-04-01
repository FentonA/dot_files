#!/usr/bin/env bash
# aws.sh - Sets up AWS CLI profile structure
# Secrets are NOT stored here - only profile structure
# Run: bash aws.sh

set -e

echo "===> Setting up AWS profiles..."

mkdir -p ~/.aws

# Create config file with named profiles
# Add new profiles here as needed
cat >~/.aws/config <<'EOF'
[default]
region = us-east-1
output = json

[profile clickk]
region = us-east-1
output = json

[profile careerplug]
region = us-east-1
output = json
EOF

# Create credentials file if it doesn't exist
# You'll need to fill in the actual keys
if [ ! -f ~/.aws/credentials ]; then
  cat >~/.aws/credentials <<'EOF'
[default]
aws_access_key_id = REPLACE_ME
aws_secret_access_key = REPLACE_ME

[clickk]
aws_access_key_id = REPLACE_ME
aws_secret_access_key = REPLACE_ME

[careerplug]
aws_access_key_id = REPLACE_ME
aws_secret_access_key = REPLACE_ME
EOF
  echo "===> Created ~/.aws/credentials - fill in your keys"
else
  echo "===> ~/.aws/credentials already exists, skipping"
fi

chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config

echo "===> AWS profile structure ready"
echo "     Switch profiles with: awsp <profile>"
echo "     Current profile: \$AWS_PROFILE"
