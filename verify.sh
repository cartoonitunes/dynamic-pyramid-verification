#!/bin/bash
set -e

CONTRACT="0xa9e4e3b1da2462752aea980698c335e70e9ab26c"
# On-chain creation bytecode (2,549 bytes)
EXPECTED=$(cat onchain-creation.hex)

echo "Contract: $CONTRACT"
echo "Compiler: solc v0.2.0 native C++ (webthree-umbrella v1.1.2), optimizer ON"
echo ""

# Compile with Docker
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
