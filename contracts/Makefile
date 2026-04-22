# EcoDive Contracts — Makefile
# All deploy/verify commands inject secrets from 1Password (op run).
# Install 1Password CLI: https://developer.1password.com/docs/cli/get-started/
#
# Usage:
#   make test              — run tests (no secrets needed)
#   make coverage          — coverage report
#   make deploy-sepolia    — deploy to Base Sepolia via 1Password
#   make verify-sepolia    — verify on Basescan via 1Password
#   make wallet-new        — generate a fresh deployer wallet (prints to stdout → save in 1Password)
#   make slither           — static analysis

.PHONY: test coverage deploy-sepolia dry-run-sepolia slither wallet-new fmt

# ── Local (no secrets) ───────────────────────────────────────────────────────

test:
	forge test -vv

coverage:
	forge coverage --report lcov && genhtml lcov.info --output-dir coverage-html

fmt:
	forge fmt

slither:
	slither . --compile-force-framework foundry --exclude-dependencies

# ── Wallet utils ─────────────────────────────────────────────────────────────

# Generate a fresh wallet — output shows address + private key.
# Copy both into 1Password item "deployer-wallet-sepolia" in vault "EcoDive".
# WARNING: output is visible in terminal history — clear after saving.
wallet-new:
	cast wallet new

# ── Testnet (Base Sepolia) ───────────────────────────────────────────────────

# Dry run — no broadcast, no fees
dry-run-sepolia:
	op run --env-file=.env.op -- \
	  forge script script/DeployTestnet.s.sol:DeployTestnet \
	    --rpc-url base_sepolia \
	    -vvv

# Broadcast + verify on Basescan
deploy-sepolia:
	op run --env-file=.env.op -- \
	  forge script script/DeployTestnet.s.sol:DeployTestnet \
	    --rpc-url base_sepolia \
	    --broadcast \
	    --verify \
	    -vvv
