// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { Treasury } from "../src/Treasury.sol";
import { ECOD } from "../src/ECOD.sol";
import { PLASTIC } from "../src/PLASTIC.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TreasuryTest is Test {
    Treasury public treasury;
    ECOD public ecod;
    PLASTIC public plastic;

    address public admin = makeAddr("admin");
    address public publisher = makeAddr("publisher");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public stranger = makeAddr("stranger");

    // ── helpers ──────────────────────────────────────────────────────────────

    /// Build a 2-leaf Merkle tree and return (root, aliceProof, bobProof)
    function _buildTree(
        address aliceAddr,
        uint256 aliceEcod,
        uint256 alicePlastic,
        uint256 epoch,
        bytes32 aliceCleanupId,
        address bobAddr,
        uint256 bobEcod,
        uint256 bobPlastic,
        bytes32 bobCleanupId
    ) internal pure returns (bytes32 root, bytes32[] memory aliceProof, bytes32[] memory bobProof) {
        bytes32 leafAlice =
            keccak256(abi.encodePacked(aliceAddr, aliceEcod, alicePlastic, epoch, aliceCleanupId));
        bytes32 leafBob =
            keccak256(abi.encodePacked(bobAddr, bobEcod, bobPlastic, epoch, bobCleanupId));

        // Standard sorted-pair Merkle root
        (bytes32 left, bytes32 right) =
            leafAlice < leafBob ? (leafAlice, leafBob) : (leafBob, leafAlice);
        root = keccak256(abi.encodePacked(left, right));

        aliceProof = new bytes32[](1);
        aliceProof[0] = leafBob;

        bobProof = new bytes32[](1);
        bobProof[0] = leafAlice;
    }

    // ── setup ─────────────────────────────────────────────────────────────────

    function setUp() public {
        vm.startPrank(admin);

        ecod = new ECOD(admin, admin, admin, admin, admin, admin, admin);
        plastic = new PLASTIC(admin);
        treasury = new Treasury(admin, publisher, address(ecod), address(plastic));

        // Grant Treasury MINTER_ROLE on PLASTIC
        plastic.grantRole(plastic.MINTER_ROLE(), address(treasury));

        // Fund Treasury with ECOD (treasury receives 30M from constructor)
        ecod.transfer(address(treasury), 1_000_000 * 1e18);

        vm.stopPrank();
    }

    // ── constructor ───────────────────────────────────────────────────────────

    function test_Constructor() public view {
        assertEq(address(treasury.ECOD_TOKEN()), address(ecod));
        assertEq(address(treasury.PLASTIC_TOKEN()), address(plastic));
        assertEq(treasury.currentEpoch(), 0);
        assertTrue(treasury.hasRole(treasury.PUBLISHER_ROLE(), publisher));
        assertTrue(treasury.hasRole(treasury.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_RevertWhen_ZeroAddressInConstructor() public {
        vm.expectRevert(Treasury.InvalidAddress.selector);
        new Treasury(address(0), publisher, address(ecod), address(plastic));

        vm.expectRevert(Treasury.InvalidAddress.selector);
        new Treasury(admin, address(0), address(ecod), address(plastic));

        vm.expectRevert(Treasury.InvalidAddress.selector);
        new Treasury(admin, publisher, address(0), address(plastic));

        vm.expectRevert(Treasury.InvalidAddress.selector);
        new Treasury(admin, publisher, address(ecod), address(0));
    }

    // ── publishRoot ───────────────────────────────────────────────────────────

    function test_PublishRoot() public {
        bytes32 root = keccak256("test-root");
        vm.prank(publisher);
        vm.expectEmit(true, false, false, true);
        emit Treasury.RootPublished(1, root, "ipfs://Qm");
        treasury.publishRoot(root, "ipfs://Qm");

        assertEq(treasury.currentEpoch(), 1);
        assertEq(treasury.epochRoot(1), root);
    }

    function test_PublishMultipleEpochs() public {
        vm.startPrank(publisher);
        treasury.publishRoot(keccak256("root1"), "");
        treasury.publishRoot(keccak256("root2"), "");
        treasury.publishRoot(keccak256("root3"), "");
        vm.stopPrank();
        assertEq(treasury.currentEpoch(), 3);
    }

    function test_RevertWhen_PublishZeroRoot() public {
        vm.prank(publisher);
        vm.expectRevert(Treasury.InvalidRoot.selector);
        treasury.publishRoot(bytes32(0), "");
    }

    function test_RevertWhen_PublishUnauthorized() public {
        vm.prank(stranger);
        vm.expectRevert();
        treasury.publishRoot(keccak256("x"), "");
    }

    // ── claim ─────────────────────────────────────────────────────────────────

    function test_ClaimEcodAndPlastic() public {
        uint256 aliceEcod = 100 * 1e18;
        uint256 alicePlastic = 5 * 1e18;
        bytes32 aliceCleanupId = keccak256("cleanup-alice-1");
        bytes32 bobCleanupId = keccak256("cleanup-bob-1");

        // Publish epoch 1
        vm.prank(publisher);
        (bytes32 root, bytes32[] memory aliceProof,) = _buildTree(
            alice, aliceEcod, alicePlastic, 1, aliceCleanupId,
            bob, 50 * 1e18, 2 * 1e18, bobCleanupId
        );
        treasury.publishRoot(root, "ipfs://test");

        uint256 ecodBefore = ecod.balanceOf(alice);
        uint256 plasticBefore = plastic.balanceOf(alice);

        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Treasury.Claimed(alice, 1, aliceCleanupId, aliceEcod, alicePlastic);
        treasury.claim(1, aliceEcod, alicePlastic, aliceCleanupId, aliceProof);

        assertEq(ecod.balanceOf(alice), ecodBefore + aliceEcod);
        assertEq(plastic.balanceOf(alice), plasticBefore + alicePlastic);
        assertTrue(treasury.hasClaimed(1, alice));
    }

    function test_ClaimEcodOnly() public {
        uint256 aliceEcod = 200 * 1e18;
        bytes32 cleanupId = keccak256("cleanup-ecod-only");

        bytes32 leaf = keccak256(abi.encodePacked(alice, aliceEcod, uint256(0), uint256(1), cleanupId));
        bytes32 root = keccak256(abi.encodePacked(leaf, leaf));

        // single-leaf: proof is empty, root is double-hash of leaf
        // use a single-leaf tree instead
        root = leaf; // single leaf tree: root == leaf

        // For single-leaf we need a different setup - use a two-leaf tree with same data
        bytes32 bobCleanupId = keccak256("bob-dummy");
        (bytes32 root2, bytes32[] memory aliceProof,) = _buildTree(
            alice, aliceEcod, 0, 1, cleanupId,
            bob, 0, 0, bobCleanupId
        );

        vm.prank(publisher);
        treasury.publishRoot(root2, "");

        vm.prank(alice);
        treasury.claim(1, aliceEcod, 0, cleanupId, aliceProof);

        assertEq(ecod.balanceOf(alice), aliceEcod);
        assertEq(plastic.balanceOf(alice), 0);
    }

    function test_RevertWhen_ClaimTwice() public {
        bytes32 cleanupId = keccak256("cleanup-double");
        bytes32 bobCleanupId = keccak256("bob-2");
        (bytes32 root, bytes32[] memory aliceProof,) = _buildTree(
            alice, 10 * 1e18, 1 * 1e18, 1, cleanupId,
            bob, 5 * 1e18, 0, bobCleanupId
        );

        vm.prank(publisher);
        treasury.publishRoot(root, "");

        vm.prank(alice);
        treasury.claim(1, 10 * 1e18, 1 * 1e18, cleanupId, aliceProof);

        vm.prank(alice);
        vm.expectRevert(Treasury.AlreadyClaimed.selector);
        treasury.claim(1, 10 * 1e18, 1 * 1e18, cleanupId, aliceProof);
    }

    function test_RevertWhen_InvalidProof() public {
        bytes32 cleanupId = keccak256("cleanup-bad-proof");
        bytes32 bobCleanupId = keccak256("bob-3");
        (bytes32 root,,) = _buildTree(
            alice, 10 * 1e18, 0, 1, cleanupId,
            bob, 5 * 1e18, 0, bobCleanupId
        );

        vm.prank(publisher);
        treasury.publishRoot(root, "");

        bytes32[] memory badProof = new bytes32[](1);
        badProof[0] = keccak256("wrong");

        vm.prank(alice);
        vm.expectRevert(Treasury.InvalidProof.selector);
        treasury.claim(1, 10 * 1e18, 0, cleanupId, badProof);
    }

    function test_RevertWhen_EpochNotFound() public {
        bytes32[] memory proof = new bytes32[](0);
        vm.prank(alice);
        vm.expectRevert(Treasury.EpochNotFound.selector);
        treasury.claim(99, 100, 0, keccak256("x"), proof);
    }

    function test_RevertWhen_ZeroAmounts() public {
        vm.prank(publisher);
        treasury.publishRoot(keccak256("root"), "");

        bytes32[] memory proof = new bytes32[](0);
        vm.prank(alice);
        vm.expectRevert(Treasury.InvalidAmount.selector);
        treasury.claim(1, 0, 0, keccak256("x"), proof);
    }

    // ── withdrawTokens ────────────────────────────────────────────────────────

    function test_WithdrawTokens() public {
        uint256 balBefore = ecod.balanceOf(admin);
        uint256 treasuryBal = ecod.balanceOf(address(treasury));

        vm.prank(admin);
        vm.expectEmit(true, true, false, true);
        emit Treasury.TokensWithdrawn(address(ecod), admin, treasuryBal);
        treasury.withdrawTokens(address(ecod), admin, treasuryBal);

        assertEq(ecod.balanceOf(admin), balBefore + treasuryBal);
        assertEq(ecod.balanceOf(address(treasury)), 0);
    }

    function test_RevertWhen_WithdrawUnauthorized() public {
        vm.prank(stranger);
        vm.expectRevert();
        treasury.withdrawTokens(address(ecod), stranger, 1);
    }

    function test_RevertWhen_WithdrawZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(Treasury.InvalidAddress.selector);
        treasury.withdrawTokens(address(ecod), address(0), 1);
    }

    function test_RevertWhen_WithdrawZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(Treasury.InvalidAmount.selector);
        treasury.withdrawTokens(address(ecod), admin, 0);
    }

    // ── fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_ClaimAmounts(uint128 ecodAmt, uint128 plasticAmt) public {
        vm.assume(ecodAmt > 0 || plasticAmt > 0);
        vm.assume(ecodAmt <= 1_000_000 * 1e18);

        // Ensure treasury has enough ECOD
        if (ecod.balanceOf(address(treasury)) < ecodAmt) {
            vm.prank(admin);
            ecod.transfer(address(treasury), ecodAmt);
        }

        bytes32 cleanupId = keccak256(abi.encodePacked(ecodAmt, plasticAmt));
        bytes32 bobCleanupId = keccak256("fuzz-bob");
        (bytes32 root, bytes32[] memory aliceProof,) = _buildTree(
            alice, ecodAmt, plasticAmt, 1, cleanupId,
            bob, 0, 0, bobCleanupId
        );

        vm.prank(publisher);
        treasury.publishRoot(root, "");

        vm.prank(alice);
        treasury.claim(1, ecodAmt, plasticAmt, cleanupId, aliceProof);

        assertEq(ecod.balanceOf(alice), ecodAmt);
        assertEq(plastic.balanceOf(alice), plasticAmt);
    }
}
