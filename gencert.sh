#!/bin/bash

# No trailing slash
OUTPREFIX="./out"

# Length of private key
# 2048 or 4096 are most common
KEYBITS="4096"

# These values are required to create the CSR
# but overwritten by the CA in most cases
CSR_C="US"
CSR_ST="Being"
CSR_L="Springfield"
CSR_O="Dis"

DIV="***************************************************"

echo "Domain you want a certificate for. Wildcard certs: use \"*.example.org\""
read -rp "Domain: " DOMAIN
echo ""

# Asterisks in paths are allowed, but make things harder
if [[ "${DOMAIN}" == *'*'* ]]; then
    SLD=$(echo "${DOMAIN}" | sed 's/\*\.//g')
    NAME="${SLD}-wildcard"
else
    NAME="${SLD}"
fi

OUTPATH="${OUTPREFIX}/${NAME}"

if [ ! -d "${OUTPATH}" ]; then
    mkdir "${OUTPATH}"
fi

KEY="${NAME}.key"
CSR="${NAME}.csr"
CRT="${NAME}.crt"
PFX="${NAME}.pfx"
KEYPATH="${OUTPATH}/${KEY}"
CSRPATH="${OUTPATH}/${CSR}"
CRTPATH="${OUTPATH}/${CRT}"
PFXPATH="${OUTPATH}/${PFX}"

new_csr_from_key() {
    openssl req -new -sha256 -key ${KEYPATH} -out ${CSRPATH} \
        -subj "/C=${CSR_C}/ST=${CSR_ST}/L=${CSR_L}/O=${CSR_O}/CN=${DOMAIN}"
}

new_csr_and_key() {
    # https://unix.stackexchange.com/a/104305
    openssl req -new -sha256 -newkey rsa:${KEYBITS} -nodes \
        -keyout ${KEYPATH} -out ${CSRPATH} \
        -subj "/C=${CSR_C}/ST=${CSR_ST}/L=${CSR_L}/O=${CSR_O}/CN=${DOMAIN}"
}

csr_instructions() {
    echo ""
    echo "${DIV}"
    echo " 1. Submit CSR to CA: ${CSRPATH}"
    echo " 2. Place signed ${CRT} in ${OUTPATH}/"
    echo " 3. Re-run gencert.sh with Domain: ${DOMAIN}"
    echo "${DIV}"
    echo ""
}

new_pfx() {
    openssl pkcs12 -export -out ${PFXPATH} \
        -inkey ${KEYPATH} -in ${CRTPATH}
}

# If key and CSR exist
if [[ -f "${KEYPATH}" ]] && [[ -f "${CSRPATH}" ]]; then
    # Check for signed cert
    if [[ -f "${CRTPATH}" ]]; then
        # Check for PFX
        if [[ -f "${PFXPATH}" ]]; then
            echo "Found PFX: ${PFXPATH}"
            echo "Nothing to do."
        else
            new_pfx
        fi
   else
        echo "No signed cert found in ${OUTPATH}/"
        csr_instructions
        # TODO: Do you want to re-generate CSR and/or key?
    fi
# Key exists without CSR
elif [[ -f "${KEYPATH}" ]] && [[ ! -f "${CSRPATH}" ]]; then
    echo "Generating new CSR from existing key: ${KEYPATH}"
    new_csr_from_key
    csr_instructions
else
    echo "Generating new key and CSR"
    new_csr_and_key
    csr_instructions
fi
