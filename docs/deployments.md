# EcoDive — Deployment Addresses

Source of truth for all deployed contract addresses across networks.

## Base Sepolia (testnet)

| Contract | Address | Verified |
|---|---|---|
| ECOD | [0xa6A6f140eaD9729a49A6aaa95B0F64cD6CB31513](https://sepolia.basescan.org/address/0xa6a6f140ead9729a49a6aaa95b0f64cd6cb31513) | ✅ |
| PLASTIC | [0xa993eEC1B74262422D59c0cD5C54E549C51f912b](https://sepolia.basescan.org/address/0xa993eec1b74262422d59c0cd5c54e549c51f912b) | ✅ |

- **Chain ID:** 84532
- **Explorer:** https://sepolia.basescan.org
- **RPC:** https://sepolia.base.org
- **Deployer:** 0xE0f7296f7D4f483E18673BD27Ae225418A58DfAf
- **Deploy date:** 2026-04-22

## Base Mainnet

_Not deployed yet. Requires external audit first (see plan_realizacji.md, Faza 3.1)._

---

## Deployment runbook (Base Sepolia)

1. Generate a fresh deployer wallet (e.g. `cast wallet new`), save the address + private key securely (password manager).
2. Fund the deployer with ≥0.05 ETH on Base Sepolia:
   - https://www.alchemy.com/faucets/base-sepolia
   - https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
3. Create `contracts/.env` from `.env.example` with:
   - `DEPLOYER_PRIVATE_KEY`
   - `BASE_SEPOLIA_RPC_URL`
   - `BASESCAN_API_KEY` (from https://basescan.org/myapikey)
4. Dry run:
   ```
   cd contracts
   forge script script/DeployTestnet.s.sol:DeployTestnet \
     --rpc-url $BASE_SEPOLIA_RPC_URL
   ```
5. Broadcast + verify:
   ```
   forge script script/DeployTestnet.s.sol:DeployTestnet \
     --rpc-url $BASE_SEPOLIA_RPC_URL \
     --broadcast --verify \
     --etherscan-api-key $BASESCAN_API_KEY
   ```
6. Copy the deployed addresses into the table above and commit.
