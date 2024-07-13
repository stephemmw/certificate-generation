#!/bin/bash

# Define paths
KEY_PATH="path/to/where/you/want/private.key"
CERT_PATH="path/to/where/you/want/server.crt"
CONFIG_PATH="path/to/openssl.cnf"

# Check if the configuration file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file not found: $CONFIG_PATH"
    exit 1
fi

# Generate the private key
echo "Generating private key..."
openssl genpkey -algorithm RSA -out "$KEY_PATH" -aes256

# Check if the private key was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to generate private key."
    exit 1
fi

# Generate the self-signed certificate
echo "Generating self-signed certificate..."
openssl req -new -x509 -key "$KEY_PATH" -out "$CERT_PATH" -config "$CONFIG_PATH" -extensions req_ext

# Check if the certificate was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to generate certificate."
    exit 1
fi

echo "Private key and certificate have been generated successfully."
echo "Private key: $KEY_PATH"
echo "Certificate: $CERT_PATH"
