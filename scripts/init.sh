

#!/bin/bash

# Replace 'your_key_file' with the path to the SSH key file you want to create
key_file="local-data/vult_ssh_key"

# Check if the key file exists
if [ ! -f "$key_file" ]; then
  echo "Generating new key..."
  # Generate the SSH key using ssh-keygen
  ssh-keygen -t rsa -b 4096 -f "$key_file" -q -N ''
  
  echo "SSH key successfully generated at $key_file"
else
  echo "SSH key already exists at $key_file"
fi