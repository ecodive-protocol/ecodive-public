// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPLASTIC {
    function mintCleanup(address to, uint256 amount, bytes32 cleanupId) external;
}

/// @title Treasury — Clean-to-Earn Merkle reward distributor
/// @notice Backend publishes a Merkle root daily; users claim ECOD + PLASTIC rewards.
/// @dev Leaf encoding: keccak256(abi.encodePacked(account, ecodAmount, plasticAmount, epoch, cleanupId))
///      Each (account, epoch) pair can be claimed only once.
contract Treasury is AccessControl {
    using SafeERC20 for IERC20;

    // ============ Errors ============

    error InvalidRoot();
    error InvalidProof();
    error AlreadyClaimed();
    error InvalidAddress();
    error InvalidAmount();
    error EpochNotFound();

    // ============ Events ============

    event RootPublished(uint256 indexed epoch, bytes32 root, string metadataUri);
    event Claimed(
        address indexed account,
        uint256 indexed epoch,
        bytes32 indexed cleanupId,
        uint256 ecodAmount,
        uint256 plasticAmount
    );
    event TokensWithdrawn(address indexed token, address indexed to, uint256 amount);

    // ============ Roles ============

    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

    // ============ State ============

    IERC20 public immutable ECOD_TOKEN;
    IPLASTIC public immutable PLASTIC_TOKEN;

    /// @notice epoch => Merkle root
    mapping(uint256 => bytes32) public epochRoot;

    /// @notice epoch => account => claimed
    mapping(uint256 => mapping(address => bool)) public hasClaimed;

    /// @notice Latest epoch index
    uint256 public currentEpoch;

    // ============ Constructor ============

    /// @param admin         Account receiving DEFAULT_ADMIN_ROLE
    /// @param publisher     Backend account publishing daily Merkle roots (PUBLISHER_ROLE)
    /// @param ecodToken     ECOD token address
    /// @param plasticToken  PLASTIC token address
    constructor(address admin, address publisher, address ecodToken, address plasticToken) {
        if (
            admin == address(0) || publisher == address(0) || ecodToken == address(0)
                || plasticToken == address(0)
        ) {
            revert InvalidAddress();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PUBLISHER_ROLE, publisher);

        ECOD_TOKEN = IERC20(ecodToken);
        PLASTIC_TOKEN = IPLASTIC(plasticToken);
    }

    // ============ Publisher ============

    /// @notice Publish a new daily Merkle root.
    /// @param root        Merkle root of all (account, ecodAmount, plasticAmount, epoch, cleanupId) leaves.
    /// @param metadataUri IPFS URI of the full leaf dataset (transparency).
    function publishRoot(bytes32 root, string calldata metadataUri)
        external
        onlyRole(PUBLISHER_ROLE)
    {
        if (root == bytes32(0)) revert InvalidRoot();
        unchecked {
            ++currentEpoch;
        }
        epochRoot[currentEpoch] = root;
        emit RootPublished(currentEpoch, root, metadataUri);
    }

    // ============ User ============

    /// @notice Claim ECOD and PLASTIC rewards for a specific epoch.
    /// @param epoch        Epoch index (from `currentEpoch` at time of root publication).
    /// @param ecodAmount   ECOD amount in wei as encoded in the leaf.
    /// @param plasticAmount PLASTIC amount in wei (1e18 = 1 kg) as encoded in the leaf.
    /// @param cleanupId    Off-chain cleanup record ID as encoded in the leaf.
    /// @param proof        Merkle proof.
    function claim(
        uint256 epoch,
        uint256 ecodAmount,
        uint256 plasticAmount,
        bytes32 cleanupId,
        bytes32[] calldata proof
    ) external {
        if (epochRoot[epoch] == bytes32(0)) revert EpochNotFound();
        if (hasClaimed[epoch][msg.sender]) revert AlreadyClaimed();
        if (ecodAmount == 0 && plasticAmount == 0) revert InvalidAmount();

        bytes32 leaf =
            keccak256(abi.encodePacked(msg.sender, ecodAmount, plasticAmount, epoch, cleanupId));

        if (!MerkleProof.verifyCalldata(proof, epochRoot[epoch], leaf)) revert InvalidProof();

        hasClaimed[epoch][msg.sender] = true;

        if (ecodAmount > 0) {
            ECOD_TOKEN.safeTransfer(msg.sender, ecodAmount);
        }
        if (plasticAmount > 0) {
            PLASTIC_TOKEN.mintCleanup(msg.sender, plasticAmount, cleanupId);
        }

        emit Claimed(msg.sender, epoch, cleanupId, ecodAmount, plasticAmount);
    }

    // ============ Admin ============

    /// @notice Withdraw stuck ERC-20 tokens (admin only).
    /// @dev For recovering ECOD that was not yet distributed.
    function withdrawTokens(address token, address to, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (to == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(to, amount);
        emit TokensWithdrawn(token, to, amount);
    }
}
