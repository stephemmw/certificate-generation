# Define paths
$KeyPath = "C:/path/to/your/certificate/private.key"
$CertPath = "C:/path/to/your/certificate/server.crt"
$ConfigPath = "C:/path/to/your/openssl.cnf"

# Check if the configuration file exists
if (-not (Test-Path $ConfigPath)) {
    Write-Host "Configuration file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}

# Generate the private key
Write-Host "Generating private key..."
$genKeyCommand = "openssl genpkey -algorithm RSA -out `"$KeyPath`" -aes256"
Invoke-Expression $genKeyCommand

# Check if the private key was created successfully
if (-not (Test-Path $KeyPath)) {
    Write-Host "Failed to generate private key." -ForegroundColor Red
    exit 1
}

# Generate the self-signed certificate
Write-Host "Generating self-signed certificate..."
$genCertCommand = "openssl req -new -x509 -key `"$KeyPath`" -out `"$CertPath`" -config `"$ConfigPath`" -extensions req_ext"
Invoke-Expression $genCertCommand

# Check if the certificate was created successfully
if (-not (Test-Path $CertPath)) {
    Write-Host "Failed to generate certificate." -ForegroundColor Red
    exit 1
}

Write-Host "Private key and certificate have been generated successfully."
Write-Host "Private key: $KeyPath"
Write-Host "Certificate: $CertPath"
