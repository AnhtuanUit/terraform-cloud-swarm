#!/usr/bin/env bash

# Processing JSON in shell scripts
# https://www.terraform.io/docs/providers/external/data_source.html#processing-json-in-shell-scripts

# Exit if any of the intermediate steps fail
set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "HOST=\(.host)"')"

# Function to attempt SSH connection
ssh_connect() {
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@"$HOST" docker swarm join-token manager -q
}

# Call the retry_ssh_connect function
MANAGER=$(ssh_connect)

# Produce a JSON object containing the tokens
jq -n --arg manager "$MANAGER" \
    '{"manager":$manager}'