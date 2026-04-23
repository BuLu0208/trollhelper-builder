#!/bin/bash
# generate_victim_cert.sh - Generate victim.p12 for TrollHelper OTA signing
# Based on the original TrollStore make_cert.sh
# Usage: ./generate_victim_cert.sh [TEAM_ID]

set -e

TEAM_ID="${1:-MRLQS75089}"

echo "Generating certificates for Team ID: $TEAM_ID"

# Step 1: Root CA
openssl req -newkey rsa:2048 -nodes -keyout root_key.pem -x509 -days 3650 -out root_certificate.pem \
    -subj "/C=CA/O=TrollStore/OU=$TEAM_ID/CN=TrollStore iPhone Root CA" \
    -addext "1.2.840.113635.100.6.2.18=DER:0500" \
    -addext "basicConstraints=critical, CA:true" \
    -addext "keyUsage=critical, digitalSignature, keyCertSign, cRLSign" 2>/dev/null

# Step 2: Code Signing CA
openssl req -newkey rsa:2048 -nodes -keyout codeca_key.pem -out codeca_certificate.csr \
    -subj "/C=CA/O=TrollStore/OU=$TEAM_ID/CN=TrollStore iPhone Certification Authority" \
    -addext "1.2.840.113635.100.6.2.18=DER:0500" \
    -addext "basicConstraints=critical, CA:true" \
    -addext "keyUsage=critical, keyCertSign, cRLSign" 2>/dev/null

openssl x509 -req -CAkey root_key.pem -CA root_certificate.pem -days 3650 \
    -in codeca_certificate.csr -out codeca_certificate.pem -CAcreateserial -copy_extensions copyall 2>/dev/null

# Step 3: Developer certificate
openssl req -newkey rsa:2048 -nodes -keyout dev_key.pem -out dev_certificate.csr \
    -subj "/C=CA/O=TrollStore/OU=$TEAM_ID/CN=TrollStore iPhone OS Application Signing" \
    -addext "basicConstraints=critical, CA:false" \
    -addext "keyUsage = critical, digitalSignature" \
    -addext "extendedKeyUsage = codeSigning" \
    -addext "1.2.840.113635.100.6.1.3=DER:0500" 2>/dev/null

openssl x509 -req -CAkey codeca_key.pem -CA codeca_certificate.pem -days 3650 \
    -in dev_certificate.csr -out dev_certificate.pem -CAcreateserial -copy_extensions copyall 2>/dev/null

# Step 4: Create certificate chain and export p12
cat codeca_certificate.pem root_certificate.pem > certificate_chain.pem
openssl pkcs12 -export -in dev_certificate.pem -inkey dev_key.pem -certfile certificate_chain.pem \
    -keypbe NONE -certpbe NONE -passout pass: \
    -out victim.p12 -name "TrollStore iPhone OS Application Signing" 2>/dev/null

# Cleanup
rm -f certificate_chain.pem codeca_certificate.csr codeca_certificate.pem codeca_key.pem
rm -f dev_certificate.csr dev_certificate.pem dev_key.pem root_certificate.pem root_key.pem
rm -f root_certificate.srl codeca_certificate.srl

echo "Generated victim.p12 ($([ $(wc -c < victim.p12) / 1024 ]KB))"
