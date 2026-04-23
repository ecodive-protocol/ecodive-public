// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title Signer — EIP-712 off-chain authorisation for cleanup claims
/// @notice Backend signs a ClaimAuthorisation struct; user submits the signature on-chain.
///         This enables gasless-style authorisation without a relayer (user pays gas, backend authorises).
/// @dev Replay protection: each (cleanupId) can be used only once.
///      The signature must be produced by an account holding SIGNER_ROLE.
contract Signer is AccessControl, EIP712 {
    using ECDSA for bytes32;

    // ============ Errors ============

    error InvalidAddress();
    error InvalidSignature();
    error AlreadyUsed();
    error ExpiredSignature();

    // ============ Events ============

    event AuthorisationUsed(bytes32 indexed cleanupId, address indexed user, uint256 amount);
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);

    // ============ Roles ============

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    // ============ EIP-712 type hash ============

    /// @dev ClaimAuthorisation(address user,uint256 amount,bytes32 cleanupId,uint256 deadline)
    bytes32 public constant CLAIM_AUTHORISATION_TYPEHASH = keccak256(
        "ClaimAuthorisation(address user,uint256 amount,bytes32 cleanupId,uint256 deadline)"
    );

    // ============ State ============

    /// @notice Tracks used cleanupIds to prevent replay
    mapping(bytes32 => bool) public usedCleanupIds;

    // ============ Constructor ============

    /// @param admin  Account receiving DEFAULT_ADMIN_ROLE
    /// @param signer Backend account authorised to sign claims (SIGNER_ROLE)
    constructor(address admin, address signer) EIP712("EcoDiveSigner", "1") {
        if (admin == address(0) || signer == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SIGNER_ROLE, signer);
        emit SignerAdded(signer);
    }

    // ============ External ============

    /// @notice Verify an EIP-712 ClaimAuthorisation signature.
    /// @dev Reverts if invalid, expired, or already used. Marks cleanupId as used on success.
    ///      Caller (e.g. Treasury or another contract) is responsible for the actual token transfer.
    /// @param user      The user who is claiming.
    /// @param amount    The authorised amount.
    /// @param cleanupId Unique cleanup identifier — replay guard.
    /// @param deadline  Unix timestamp after which the signature is invalid.
    /// @param signature Raw 65-byte ECDSA signature.
    function verifyAndConsume(
        address user,
        uint256 amount,
        bytes32 cleanupId,
        uint256 deadline,
        bytes calldata signature
    ) external {
        if (user == address(0)) revert InvalidAddress();
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > deadline) revert ExpiredSignature();
        if (usedCleanupIds[cleanupId]) revert AlreadyUsed();

        bytes32 structHash =
            keccak256(abi.encode(CLAIM_AUTHORISATION_TYPEHASH, user, amount, cleanupId, deadline));
        bytes32 digest = _hashTypedDataV4(structHash);
        address recovered = digest.recover(signature);

        if (!hasRole(SIGNER_ROLE, recovered)) revert InvalidSignature();

        usedCleanupIds[cleanupId] = true;
        emit AuthorisationUsed(cleanupId, user, amount);
    }

    /// @notice Check if a given signature would be valid (read-only, no state change).
    function isValid(
        address user,
        uint256 amount,
        bytes32 cleanupId,
        uint256 deadline,
        bytes calldata signature
    ) external view returns (bool) {
        if (user == address(0)) return false;
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp > deadline) return false;
        if (usedCleanupIds[cleanupId]) return false;

        bytes32 structHash =
            keccak256(abi.encode(CLAIM_AUTHORISATION_TYPEHASH, user, amount, cleanupId, deadline));
        bytes32 digest = _hashTypedDataV4(structHash);
        address recovered = digest.recover(signature);
        return hasRole(SIGNER_ROLE, recovered);
    }

    // ============ Admin ============

    /// @notice Grant SIGNER_ROLE to a new backend key (key rotation).
    function addSigner(address signer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (signer == address(0)) revert InvalidAddress();
        _grantRole(SIGNER_ROLE, signer);
        emit SignerAdded(signer);
    }

    /// @notice Revoke SIGNER_ROLE from a compromised backend key.
    function removeSigner(address signer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (signer == address(0)) revert InvalidAddress();
        _revokeRole(SIGNER_ROLE, signer);
        emit SignerRemoved(signer);
    }

    // ============ View ============

    /// @notice Returns the EIP-712 domain separator (for frontend / SDK use).
    function domainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
