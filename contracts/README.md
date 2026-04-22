# EcoDive Smart Contracts

Solidity contracts for the EcoDive protocol, built with Foundry.

## Contracts

| Contract | Description |
|---|---|
| `ECOD.sol` | ERC-20 governance token, 100M supply, 3% DEX tax |
| `PLASTIC.sol` | ERC-20 RWA credit, 1 token = 1 kg verified plastic |

## Requirements

- [Foundry](https://book.getfoundry.sh/) 1.5+

## Setup

```bash
# Install dependencies (run once after cloning)
forge install OpenZeppelin/openzeppelin-contracts@v5.1.0 foundry-rs/forge-std

# Build
forge build

# Run tests
forge test -vv

# Coverage
forge coverage --report summary
```

## Test Status

- `ECOD.sol` — 100% line / branch / function coverage
- `PLASTIC.sol` — 100% line / branch / function coverage

## Deployment

Configure `.env` from `.env.example`, then:

```bash
# Base Sepolia testnet
forge script script/DeployTestnet.s.sol \
  --rpc-url base_sepolia \
  --broadcast \
  --verify
```

## License

MIT
