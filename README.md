# DynamicPyramid Contract Verification

**Byte-for-byte verified** creation bytecode for the DynamicPyramid contract deployed on Ethereum mainnet.

## Contract

- **Address**: [`0xa9e4e3b1da2462752aea980698c335e70e9ab26c`](https://etherscan.io/address/0xa9e4e3b1da2462752aea980698c335e70e9ab26c)
- **Deployed**: February 23, 2016 (block 1,049,304)
- **Deployer**: `0xe5478bbde21a0a38401a4e9cc57cfd11dec15b66`
- **ETH locked**: 37 ETH (participants still awaiting payout)
- **Creation bytecode**: 2,549 bytes

## Compiler

- **Version**: solc v0.2.0 (native C++ build, webthree-umbrella v1.1.2)
- **Optimizer**: ON

The JS soljson compiler produces different bytecode for this era. Only the native C++ compiler built from [webthree-umbrella v1.1.2](https://github.com/ethereum/webthree-umbrella/releases/tag/v1.1.2) reproduces the exact on-chain bytecode.

## Verification

```bash
# Build the Docker image first (one-time)
docker build -t solc-umbrella https://raw.githubusercontent.com/cartoonitunes/doubler-verification/main/Dockerfile

# Run verification
chmod +x verify.sh
./verify.sh
```

## How to Reproduce

Build native C++ solc from webthree-umbrella v1.1.2:

```bash
docker run --rm -v "$(pwd):/src" solc-umbrella sh -c \
  "cd /src && /umbrella/build/solidity/solc/solc --optimize --bin DynamicPyramid.sol"
```

Compare the `DynamicPyramid` section output against `onchain-creation.hex`.

## Contract Behavior

A self-adjusting pyramid scheme that changes payout multipliers as participation grows, designed to extend its lifespan.

- **Entry**: 1 ETH minimum (smaller amounts go to fees without entering the pyramid)
- **Initial multiplier**: 3x (receive 3 ETH when paid out)
- **At 10 participants**: multiplier drops to 2x
- **At 25 participants**: multiplier drops to 1.5x
- **Fee**: 10% (halved to 5% for deposits of 50+ ETH)
- **Total participants**: 140 (as of final state)
- **Still waiting for payout**: 136 participants

### Key Finding

The contract ran out of funds before completing its payout queue. 136 of 140 participants are still waiting. 37 ETH remains locked, not enough to cover the remaining obligations. The creator (`0xe5478b...`) extracted fees but left participants waiting.

## Links

- [EthereumHistory.com](https://www.ethereumhistory.com/contract/0xa9e4e3b1da2462752aea980698c335e70e9ab26c)
- [awesome-ethereum-proofs](https://github.com/cartoonitunes/awesome-ethereum-proofs)
