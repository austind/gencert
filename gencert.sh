#!/bin/bash

# No trailing slash
OUTPREFIX="./out"

# These values are required for the CSR
# but overwritten by the CA in most cases
CSR_C="US"
CSR_ST="Being"
CSR_L="Springfield"
CSR_O="Dis"

echo "Domain you want a certificate for. Wildcard certs: use \"*.example.org\""
read -rp "Domain: " DOMAIN

if [[ "${DOMAIN}" == *'*'* ]]; then
    SLD=$(echo "${DOMAIN}" | sed 's/\*\.//g')
    NAME="${SLD}-wildcard"
else
    NAME="${SLD}"
fi

OUTPATH="${OUTPREFIX}/${NAME}"
OUTNAME="${OUTPATH}/${NAME}"

if [ ! -d "${OUTPATH}" ]; then
    mkdir "${OUTPATH}"
fi

KEY="${OUTNAME}.key"
CSR="${OUTNAME}.csr"

# If key exists without CSR
if [[ -f "${KEY}" ]] && [[ ! -f "$CSR" ]]; then
    # Ask to rekey or generate CSR based on key
    :
fi

openssl req -new -sha256 -newkey rsa:4096 -nodes \
    -keyout ${OUTNAME}.key -out ${OUTNAME}.csr \
    -subj "/C=${CSR_C}/ST=${CSR_ST}/L=${CSR_L}/O=${CSR_O}/CN=${DOMAIN}"
