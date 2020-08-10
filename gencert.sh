#!/bin/bash

read -rp "Domain: " DOMAIN
if [ ! -d "./${DOMAIN}" ]; then
    mkdir "./${DOMAIN}"
fi
OUTPUT="./${DOMAIN}/${DOMAIN}"
echo "Generating new private key..."
openssl genrsa -out "${OUTPUT}.key" 2048
echo "Generating CSR for ${OUTPUT}"
openssl req -new -sha256 -key "${OUTPUT}.key" -out "${OUTPUT}.csr"

