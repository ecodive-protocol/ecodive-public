// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title PLASTIC — Real-World-Asset credit token
/// @notice Each PLASTIC token represents 1 kilogram of verified plastic removed from the environment.
/// @dev Minting is restricted to the MINTER_ROLE (the verification oracle / Treasury contract).
///      Tokens are burned by corporations to produce on-chain ESG/CSRD offset certificates.
///      Burns emit a `BurnCertificate` event for off-chain indexing and reporting.
contract PLASTIC is ERC20, ERC20Burnable, AccessControl {
    // ============ Errors ============

    error InvalidAddress();
    error InvalidAmount();
    error CertificateMetadataTooLong();

    // ============ Events ============

    /// @notice Emitted when plastic credits are minted after verification
    /// @param to Recipient of the credits
    /// @param amount Amount in wei (1e18 = 1 kg)
    /// @param cleanupId Off-chain cleanup record identifier (UUID hash)
    event CleanupMinted(address indexed to, uint256 amount, bytes32 indexed cleanupId);

    /// @notice Emitted when a corporation burns credits as an ESG offset
    /// @param burner Address performing the burn
    /// @param amount Amount burned
    /// @param certificateId Unique certificate identifier (hash of burner + block.timestamp + amount)
    /// @param metadata Arbitrary metadata (e.g. company name, reporting period) — max 256 bytes
    event BurnCertificate(address indexed burner, uint256 amount, bytes32 indexed certificateId, bytes metadata);

    // ============ Constants ============

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_METADATA_LENGTH = 256;

    // ============ State ============

    /// @notice Total kilograms ever minted (for transparency dashboards)
    uint256 public totalKgMinted;

    /// @notice Total kilograms ever burned as offsets (for transparency dashboards)
    uint256 public totalKgBurned;

    // ============ Constructor ============

    /// @param admin Account receiving DEFAULT_ADMIN_ROLE and MINTER_ROLE
    constructor(address admin) ERC20("EcoDive Plastic Credit", "PLASTIC") {
        if (admin == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    // ============ External — Minting ============

    /// @notice Mint new PLASTIC credits after a verified cleanup
    /// @param to Recipient (Treasury contract or user)
    /// @param amount Amount in wei (1e18 = 1 kg)
    /// @param cleanupId Off-chain cleanup record identifier
    function mintCleanup(address to, uint256 amount, bytes32 cleanupId) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        totalKgMinted += amount;
        _mint(to, amount);
        emit CleanupMinted(to, amount, cleanupId);
    }

    // ============ External — Burning ============

    /// @notice Burn credits as an ESG offset, producing a certificate event
    /// @dev Emits `BurnCertificate` alongside standard ERC20 burn.
    ///      Corporations call this to produce auditable on-chain proof of plastic compensation.
    /// @param amount Amount to burn (in wei)
    /// @param metadata Optional metadata (company name, reporting period), max 256 bytes
    /// @return certificateId Unique certificate identifier
    function burnWithCertificate(uint256 amount, bytes calldata metadata) external returns (bytes32 certificateId) {
        if (amount == 0) revert InvalidAmount();
        if (metadata.length > MAX_METADATA_LENGTH) revert CertificateMetadataTooLong();

        totalKgBurned += amount;
        _burn(msg.sender, amount);

        certificateId = keccak256(abi.encodePacked(msg.sender, block.timestamp, amount, metadata));
        emit BurnCertificate(msg.sender, amount, certificateId, metadata);
    }
}
