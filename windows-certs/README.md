You **cannot run this PowerShell script directly in Command Prompt (CMD)** because:

* It uses PowerShell-specific syntax (`foreach`, here-strings `@"..."@`, `Set-Content`, etc.).
* CMD does not support such scripting structures.

---

### ✅ Options You Can Use:

#### 🔹 Option 1: **Run via PowerShell (Recommended)**

Open PowerShell and run:

```powershell
.\generate-certs.ps1
```

Or from CMD:

```cmd
powershell -ExecutionPolicy Bypass -File generate-certs.ps1
```

> This tells CMD to launch PowerShell and execute the script.

---

#### 🔹 Option 2: **CMD-Compatible Version (Very Limited)**

If you *really* must use CMD, here’s a simplified `.bat` version (but it's harder to maintain and lacks loops):

```bat
@echo off
setlocal enabledelayedexpansion

REM Create directories
mkdir certs\ca
mkdir certs\node1
mkdir certs\node2

REM Generate CA
openssl genrsa -out certs\ca\ca.key 4096
openssl req -x509 -new -nodes -key certs\ca\ca.key -sha256 -days 365 -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=elasticsearch-ca" -out certs\ca\ca.crt

REM Generate node1 cert
openssl genrsa -out certs\node1\node1.key 4096
openssl req -new -key certs\node1\node1.key -out certs\node1\node1.csr -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=node1"
echo authorityKeyIdentifier=keyid,issuer> certs\node1\node1.ext
echo basicConstraints=CA:FALSE>> certs\node1\node1.ext
echo keyUsage = digitalSignature, keyEncipherment>> certs\node1\node1.ext
echo subjectAltName = @alt_names>> certs\node1\node1.ext
echo.>> certs\node1\node1.ext
echo [alt_names]>> certs\node1\node1.ext
echo DNS.1 = node1>> certs\node1\node1.ext
echo DNS.2 = localhost>> certs\node1\node1.ext
openssl x509 -req -in certs\node1\node1.csr -CA certs\ca\ca.crt -CAkey certs\ca\ca.key -CAcreateserial -out certs\node1\node1.crt -days 365 -sha256 -extfile certs\node1\node1.ext

REM Repeat for node2
openssl genrsa -out certs\node2\node2.key 4096
openssl req -new -key certs\node2\node2.key -out certs\node2\node2.csr -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=node2"
echo authorityKeyIdentifier=keyid,issuer> certs\node2\node2.ext
echo basicConstraints=CA:FALSE>> certs\node2\node2.ext
echo keyUsage = digitalSignature, keyEncipherment>> certs\node2\node2.ext
echo subjectAltName = @alt_names>> certs\node2\node2.ext
echo.>> certs\node2\node2.ext
echo [alt_names]>> certs\node2\node2.ext
echo DNS.1 = node2>> certs\node2\node2.ext
echo DNS.2 = localhost>> certs\node2\node2.ext
openssl x509 -req -in certs\node2\node2.csr -CA certs\ca\ca.crt -CAkey certs\ca\ca.key -CAcreateserial -out certs\node2\node2.crt -days 365 -sha256 -extfile certs\node2\node2.ext

echo Certificates generated successfully!
```

Save this as `generate-certs.bat` and run with:

```cmd
generate-certs.bat
```

---

Let me know which version you prefer, or if you'd like to include a **Kibana certificate** in this too.
