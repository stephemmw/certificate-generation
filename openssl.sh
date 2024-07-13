#!/bin/bash

# Define paths
CERT_DIR="path/to/certificate"
KEY_PATH="$CERT_DIR/private.key"
CERT_PATH="$CERT_DIR/server.crt"
CONFIG_PATH="path/to/openssl.cnf"
PASSPHRASE_FILE="$CERT_DIR/passphrase.txt"

# Function to generate a random passphrase
generate_passphrase() {
    openssl rand -base64 32 | tr -d '\n' > "$PASSPHRASE_FILE"
}

# Check if the certificate directory exists, if not create it
if [ ! -d "$CERT_DIR" ]; then
    echo "Creating certificate directory: $CERT_DIR"
    mkdir -p "$CERT_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create certificate directory."
        exit 1
    fi
fi

# Check if the configuration file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Configuration file not found: $CONFIG_PATH"
    exit 1
fi

# Generate and save the passphrase
echo "Generating passphrase..."
generate_passphrase
if [ $? -ne 0 ]; then
    echo "Failed to generate passphrase."
    exit 1
fi
echo "Passphrase saved to: $PASSPHRASE_FILE"

# Generate the private key
echo "Generating private key..."
openssl genpkey -algorithm RSA -out "$KEY_PATH" -aes256 -pass file:"$PASSPHRASE_FILE"

# Check if the private key was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to generate private key."
    exit 1
fi
echo "Private key generated: $KEY_PATH"

# Generate the certificate signing request (CSR)
echo "Generating certificate signing request..."
openssl req -new -key "$KEY_PATH" -out "$CERT_DIR/server.csr" -config "$CONFIG_PATH" -passin file:"$PASSPHRASE_FILE"

# Check if the CSR was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to generate certificate signing request."
    exit 1
fi
echo "Certificate signing request generated: $CERT_DIR/server.csr"

# Generate the self-signed certificate
echo "Generating self-signed certificate..."
openssl x509 -req -days 365 -in "$CERT_DIR/server.csr" -signkey "$KEY_PATH" -out "$CERT_PATH" -passin file:"$PASSPHRASE_FILE"

# Check if the certificate was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to generate self-signed certificate."
    exit 1
fi
echo "Self-signed certificate generated: $CERT_PATH"

echo "Certificate generation process completed successfully."