# Define paths
$CertDir = "E:\xampp\apache\conf\domains\dev\certificate"
$KeyPath = Join-Path $CertDir "private.key"
$DecryptedKeyPath = Join-Path $CertDir "private_decrypted.key"
$CertPath = Join-Path $CertDir "server.crt"
$ConfigPath = "E:\xampp\apache\conf\domains\dev\openssl.cnf"
$PassphraseFile = Join-Path $CertDir "passphrase.txt"
$DecryptedKeyPath = Join-Path $CertDir "private_decrypted.key"

# Function to run OpenSSL commands
function Invoke-OpenSSL {
    param (
        [string]$Arguments
    )
    $openSSLPath = "openssl"  # Assumes OpenSSL is in PATH, adjust if necessary
    $process = Start-Process -FilePath $openSSLPath -ArgumentList $Arguments -NoNewWindow -PassThru -Wait
    if ($process.ExitCode -ne 0) {
        throw "OpenSSL command failed with exit code $($process.ExitCode)"
    }
}

# Function to generate a random passphrase
function Get-RandomPassphrase {
    $length = 32
    $characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?'
    return -join ((1..$length) | ForEach-Object { $characters | Get-Random })
}

# Create certificate directory if it doesn't exist
if (-not (Test-Path $CertDir)) {
    New-Item -ItemType Directory -Path $CertDir | Out-Null
}

# Check if the configuration file exists
if (-not (Test-Path $ConfigPath)) {
    Write-Host "Configuration file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}

try {
    # Generate and save the passphrase
    $passphrase = Get-RandomPassphrase
    $passphrase | Out-File -FilePath $PassphraseFile -NoNewline

    # Generate the private key (encrypted)
    Write-Host "Generating encrypted private key..."
    Invoke-OpenSSL "genpkey -algorithm RSA -aes256 -out `"$KeyPath`" -pass file:`"$PassphraseFile`""

    # Generate the self-signed certificate
    Write-Host "Generating self-signed certificate..."
    Invoke-OpenSSL "req -new -x509 -key `"$KeyPath`" -out `"$CertPath`" -config `"$ConfigPath`" -extensions req_ext -passin file:`"$PassphraseFile`""

    # Create a decrypted version of the private key for Apache
    Write-Host "Creating decrypted version of private key for Apache..."
    Invoke-OpenSSL "rsa -in `"$KeyPath`" -out `"$DecryptedKeyPath`" -passin file:`"$PassphraseFile`""

    Write-Host "Certificate files generated successfully:" -ForegroundColor Green
    Write-Host "Encrypted private key: $KeyPath"
    Write-Host "Decrypted private key: $DecryptedKeyPath"
    Write-Host "Certificate: $CertPath"
    Write-Host "Passphrase file: $PassphraseFile"
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    exit 1
}
