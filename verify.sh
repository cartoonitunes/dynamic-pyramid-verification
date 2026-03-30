#!/bin/bash
set -e

CONTRACT="0xa9e4e3b1da2462752aea980698c335e70e9ab26c"
# On-chain creation bytecode (2,549 bytes)
EXPECTED=$(cat onchain-creation.hex)

echo "Contract: $CONTRACT"
echo "Compiler: soljson-v0.2.0-nightly.2016.1.20+commit.67c855c5 (optimizer ON)"
echo ""

# Check if soljson nightly is available
SOLJSON="soljson-v0.2.0-nightly.2016.1.20+commit.67c855c5.js"
if [ ! -f "$SOLJSON" ]; then
    echo "Downloading soljson nightly..."
    curl -sO "https://binaries.soliditylang.org/bin/$SOLJSON"
fi

# Try soljson path first
if command -v node &>/dev/null && [ -f "$SOLJSON" ]; then
    # Use node to compile with the soljson binary
    COMPILED=$(node -e "
const solc = require('./$SOLJSON');
const fs = require('fs');
const src = fs.readFileSync('DynamicPyramid.sol', 'utf8');
const output = solc.compile(src, 1);
const contract = output.contracts['DynamicPyramid'];
process.stdout.write(contract.bytecode);
" 2>/dev/null)
    
    if [ -n "$COMPILED" ]; then
        echo "Compiled with soljson nightly"
        echo "Compiled creation bytecode: $((${#COMPILED} / 2)) bytes"
        echo "On-chain creation bytecode: $((${#EXPECTED} / 2)) bytes"
        echo ""
        
        if [ "${COMPILED,,}" = "${EXPECTED,,}" ]; then
            echo "EXACT MATCH - byte-for-byte identical ($((${#COMPILED} / 2)) bytes)"
            echo ""
            echo "Contract:  $CONTRACT"
            echo "Block:     1,049,304 (February 23, 2016)"
            echo "Deployer:  0xe5478bbde21a0a38401a4e9cc57cfd11dec15b66"
            echo "Source:    DynamicPyramid.sol"
            echo "Compiler:  soljson-v0.2.0-nightly.2016.1.20+commit.67c855c5"
            echo "Settings:  optimizer on"
            exit 0
        else
            echo "NO MATCH with soljson nightly — trying native C++..."
        fi
    fi
fi

# Fallback: native C++ via Docker (solc-umbrella)
echo "Trying native C++ solc (webthree-umbrella v1.1.2)..."
COMPILED=$(docker run --rm -v "$(pwd):/src" solc-umbrella sh -c \
  "cd /src && /umbrella/build/solidity/solc/solc --optimize --bin DynamicPyramid.sol 2>/dev/null" \
  | grep -A1 "DynamicPyramid" | tail -1)

echo "Compiled creation bytecode: $((${#COMPILED} / 2)) bytes"
echo "On-chain creation bytecode: $((${#EXPECTED} / 2)) bytes"
echo ""

if [ "${COMPILED,,}" = "${EXPECTED,,}" ]; then
    echo "EXACT MATCH - byte-for-byte identical ($((${#COMPILED} / 2)) bytes)"
    echo ""
    echo "Contract:  $CONTRACT"
    echo "Block:     1,049,304 (February 23, 2016)"
    echo "Deployer:  0xe5478bbde21a0a38401a4e9cc57cfd11dec15b66"
    echo "Source:    DynamicPyramid.sol"
    echo "Compiler:  solc v0.2.0 native C++ (webthree-umbrella v1.1.2)"
    echo "Settings:  optimizer on"
else
    echo "NO MATCH"
    exit 1
fi
