Here’s a **Windows-compatible PowerShell version** of your Bash script that creates a CA and signs certificates for `node1` and `node2`, replicating your `bash` script's functionality:

---

### ✅ PowerShell Script (save as `generate-certs.ps1`)

```powershell
$ErrorActionPreference = "Stop"

# Create folders
New-Item -ItemType Directory -Force -Path "certs\ca"
New-Item -ItemType Directory -Force -Path "certs\node1"
New-Item -ItemType Directory -Force -Path "certs\node2"

# Generate CA
openssl genrsa -out certs\ca\ca.key 4096
openssl req -x509 -new -nodes -key certs\ca\ca.key -sha256 -days 365 `
  -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=elasticsearch-ca" `
  -out certs\ca\ca.crt

# Generate node certificates
foreach ($node in @("node1", "node2")) {
    $nodePath = "certs\$node"
    openssl genrsa -out "$nodePath\$node.key" 4096
    openssl req -new -key "$nodePath\$node.key" -out "$nodePath\$node.csr" `
      -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=$node"

    $extContent = @"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $node
DNS.2 = localhost
"@

    $extContent | Set-Content -Path "$nodePath\$node.ext" -Encoding ASCII

    openssl x509 -req -in "$nodePath\$node.csr" -CA certs\ca\ca.crt -CAkey certs\ca\ca.key `
      -CAcreateserial -out "$nodePath\$node.crt" -days 365 -sha256 `
      -extfile "$nodePath\$node.ext"
}
```

---

### 📌 Notes

* Run it in **PowerShell** (not CMD).
* Make sure `openssl.exe` is available in your **PATH**. You can verify with:

  ```powershell
  openssl version
  ```
* To run:

  ```powershell
  .\generate-certs.ps1
  ```

---

Let me know if you'd like to also create certificates for **Kibana** or add **IP SANs** for Docker compatibility.
