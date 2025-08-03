#!/bin/bash

set -e

mkdir -p certs/ca certs/node1 certs/node2

# Generate CA
openssl genrsa -out certs/ca/ca.key 4096
openssl req -x509 -new -nodes -key certs/ca/ca.key -sha256 -days 365   -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=elasticsearch-ca"   -out certs/ca/ca.crt

# Generate Node Certificates
for node in node1 node2; do
  mkdir -p certs/$node
  openssl genrsa -out certs/$node/$node.key 4096
  openssl req -new -key certs/$node/$node.key -out certs/$node/$node.csr     -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=Lauki/OU=DevOps/CN=$node"

  cat > certs/$node/$node.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $node
DNS.2 = localhost
EOF

  openssl x509 -req -in certs/$node/$node.csr -CA certs/ca/ca.crt -CAkey certs/ca/ca.key     -CAcreateserial -out certs/$node/$node.crt -days 365 -sha256 -extfile certs/$node/$node.ext
done
