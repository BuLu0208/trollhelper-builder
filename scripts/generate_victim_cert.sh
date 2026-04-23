#!/bin/bash
# generate_victim_cert.sh - Generate victim.p12 for TrollHelper OTA signing
# Replacement for make_cert.sh, works on Linux with openssl
# Usage: ./generate_victim_cert.sh [TEAM_ID]

TEAM_ID="${1:-MRLQS75089}"

# Generate self-signed certificate
openssl req -x509 -newkey rsa:2048 -keyout victim.key -out victim.crt \
    -days 3650 -nodes -subj "/CN=$TEAM_ID/O=$TEAM_ID/C=US" 2>/dev/null

# Create PKCS12 container (no password)
openssl pkcs12 -export -out victim.p12 -inkey victim.key -in victim.crt \
    -password pass: 2>/dev/null

# Cleanup
rm -f victim.key victim.crt

echo "Generated victim.p12 with Team ID: $TEAM_ID"
