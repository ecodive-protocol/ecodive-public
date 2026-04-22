// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title ECOD — EcoDive Community & Governance Token
/// @notice ERC-20 governance token with a 3% DEX transaction tax.
/// @dev Tax is split: 1% treasury, 1% liquidity, 1% dev wallet.
///      Tax is only applied on transfers to/from taxed pairs (e.g. Uniswap).
///      Regular wallet-to-wallet transfers are not taxed.
contract ECOD is ERC20, AccessControl {
    // ============ Errors ============

    error InvalidWallet();
    error InvalidTaxBps();
    error AlreadyExcluded();
    error NotExcluded();

    // ============ Events ============

    event TaxWalletsUpdated(address treasury, address liquidity, address dev);
    event TaxedPairSet(address indexed pair, bool taxed);
    event ExcludedFromTax(address indexed account, bool excluded);
    event TaxCollected(address indexed from, uint256 treasuryAmount, uint256 liquidityAmount, uint256 devAmount);

    // ============ Constants ============

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Total supply: 100 million tokens
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 1e18;

    /// @notice Tax in basis points — 3% total (100 each side)
    uint16 public constant TREASURY_TAX_BPS = 100; // 1%
    uint16 public constant LIQUIDITY_TAX_BPS = 100; // 1%
    uint16 public constant DEV_TAX_BPS = 100; // 1%
    uint16 public constant TOTAL_TAX_BPS = TREASURY_TAX_BPS + LIQUIDITY_TAX_BPS + DEV_TAX_BPS;
    uint16 public constant BPS_DENOMINATOR = 10_000;

    // ============ State ============

    address public treasuryWallet;
    address public liquidityWallet;
    address public devWallet;

    /// @notice Tax is applied on transfers where either side is a taxed pair (DEX pool)
    mapping(address => bool) public isTaxedPair;

    /// @notice Excluded addresses pay no tax (e.g. treasury, initial liquidity)
    mapping(address => bool) public isExcludedFromTax;

    // ============ Constructor ============

    /// @param admin Account receiving DEFAULT_ADMIN_ROLE and ADMIN_ROLE
    /// @param liquidity Address receiving 40% of supply for DEX pool
    /// @param treasury Address receiving 30% of supply for Clean-to-Earn rewards
    /// @param presale Address receiving 15% of supply for presale
    /// @param team Address receiving 10% of supply (subject to external vesting)
    /// @param marketing Address receiving 5% of supply for airdrops and campaigns
    /// @param dev Wallet receiving the 1% dev tax
    constructor(
        address admin,
        address liquidity,
        address treasury,
        address presale,
        address team,
        address marketing,
        address dev
    ) ERC20("EcoDive", "ECOD") {
        if (
            admin == address(0) || liquidity == address(0) || treasury == address(0) || presale == address(0)
                || team == address(0) || marketing == address(0) || dev == address(0)
        ) {
            revert InvalidWallet();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);

        treasuryWallet = treasury;
        liquidityWallet = liquidity;
        devWallet = dev;

        // Exclude system wallets from tax to avoid double-taxation on setup
        isExcludedFromTax[admin] = true;
        isExcludedFromTax[liquidity] = true;
        isExcludedFromTax[treasury] = true;
        isExcludedFromTax[presale] = true;
        isExcludedFromTax[team] = true;
        isExcludedFromTax[marketing] = true;
        isExcludedFromTax[dev] = true;
        isExcludedFromTax[address(this)] = true;

        // Distribute initial supply (100M total)
        _mint(liquidity, 40_000_000 * 1e18); // 40% DEX liquidity
        _mint(treasury, 30_000_000 * 1e18); // 30% Clean-to-Earn treasury
        _mint(presale, 15_000_000 * 1e18); // 15% presale
        _mint(team, 10_000_000 * 1e18); // 10% team (vested externally)
        _mint(marketing, 5_000_000 * 1e18); // 5% marketing & airdrops
    }

    // ============ Admin ============

    /// @notice Update tax destination wallets (admin only)
    function setTaxWallets(address treasury, address liquidity, address dev) external onlyRole(ADMIN_ROLE) {
        if (treasury == address(0) || liquidity == address(0) || dev == address(0)) revert InvalidWallet();
        treasuryWallet = treasury;
        liquidityWallet = liquidity;
        devWallet = dev;
        emit TaxWalletsUpdated(treasury, liquidity, dev);
    }

    /// @notice Mark an address as a taxed DEX pair (admin only)
    /// @dev Typically called once after creating a Uniswap V4 pool
    function setTaxedPair(address pair, bool taxed) external onlyRole(ADMIN_ROLE) {
        if (pair == address(0)) revert InvalidWallet();
        isTaxedPair[pair] = taxed;
        emit TaxedPairSet(pair, taxed);
    }

    /// @notice Exclude or include an address from tax (admin only)
    function setExcludedFromTax(address account, bool excluded) external onlyRole(ADMIN_ROLE) {
        if (account == address(0)) revert InvalidWallet();
        if (excluded && isExcludedFromTax[account]) revert AlreadyExcluded();
        if (!excluded && !isExcludedFromTax[account]) revert NotExcluded();
        isExcludedFromTax[account] = excluded;
        emit ExcludedFromTax(account, excluded);
    }

    // ============ Internal overrides ============

    /// @dev Overrides ERC20 _update to apply tax on DEX transfers.
    ///      Tax triggers when neither side is excluded AND at least one side is a taxed pair.
    function _update(address from, address to, uint256 value) internal override {
        // Mint / burn path — no tax
        if (from == address(0) || to == address(0)) {
            super._update(from, to, value);
            return;
        }

        bool shouldTax = !isExcludedFromTax[from] && !isExcludedFromTax[to] && (isTaxedPair[from] || isTaxedPair[to]);

        if (!shouldTax) {
            super._update(from, to, value);
            return;
        }

        uint256 treasuryAmount = (value * TREASURY_TAX_BPS) / BPS_DENOMINATOR;
        uint256 liquidityAmount = (value * LIQUIDITY_TAX_BPS) / BPS_DENOMINATOR;
        uint256 devAmount = (value * DEV_TAX_BPS) / BPS_DENOMINATOR;
        uint256 transferAmount = value - treasuryAmount - liquidityAmount - devAmount;

        super._update(from, treasuryWallet, treasuryAmount);
        super._update(from, liquidityWallet, liquidityAmount);
        super._update(from, devWallet, devAmount);
        super._update(from, to, transferAmount);

        emit TaxCollected(from, treasuryAmount, liquidityAmount, devAmount);
    }
}
