// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { Signer } from "../src/Signer.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignerTest is Test {
    Signer public signerContract;

    address public admin = makeAddr("admin");
    address public stranger = makeAddr("stranger");

    uint256 public signerPk = 0xBEEF;
    address public signerAddr;

    // ── setup ─────────────────────────────────────────────────────────────────

    function setUp() public {
        signerAddr = vm.addr(signerPk);
        vm.prank(admin);
        signerContract = new Signer(admin, signerAddr);
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    function _sign(
        address user,
        uint256 amount,
        bytes32 cleanupId,
        uint256 deadline
    ) internal view returns (bytes memory signature) {
        bytes32 structHash = keccak256(
            abi.encode(
                signerContract.CLAIM_AUTHORISATION_TYPEHASH(),
                user,
                amount,
                cleanupId,
                deadline
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", signerContract.domainSeparator(), structHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        signature = abi.encodePacked(r, s, v);
    }

    // ── constructor ───────────────────────────────────────────────────────────

    function test_Constructor() public view {
        assertTrue(signerContract.hasRole(signerContract.SIGNER_ROLE(), signerAddr));
        assertTrue(signerContract.hasRole(signerContract.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_RevertWhen_ZeroAddressConstructor() public {
        vm.expectRevert(Signer.InvalidAddress.selector);
        new Signer(address(0), signerAddr);

        vm.expectRevert(Signer.InvalidAddress.selector);
        new Signer(admin, address(0));
    }

    // ── domainSeparator ───────────────────────────────────────────────────────

    function test_DomainSeparator_NonZero() public view {
        assertTrue(signerContract.domainSeparator() != bytes32(0));
    }

    // ── verifyAndConsume ──────────────────────────────────────────────────────

    function test_VerifyAndConsume_Valid() public {
        bytes32 cleanupId = keccak256("cleanup-1");
        uint256 deadline = block.timestamp + 1 hours;
        uint256 amount = 100 * 1e18;

        bytes memory sig = _sign(stranger, amount, cleanupId, deadline);

        assertTrue(signerContract.isValid(stranger, amount, cleanupId, deadline, sig));

        vm.expectEmit(true, true, false, true);
        emit Signer.AuthorisationUsed(cleanupId, stranger, amount);
        signerContract.verifyAndConsume(stranger, amount, cleanupId, deadline, sig);

        assertTrue(signerContract.usedCleanupIds(cleanupId));
    }

    function test_RevertWhen_ReplayAttack() public {
        bytes32 cleanupId = keccak256("cleanup-replay");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(stranger, 100 * 1e18, cleanupId, deadline);

        signerContract.verifyAndConsume(stranger, 100 * 1e18, cleanupId, deadline, sig);

        vm.expectRevert(Signer.AlreadyUsed.selector);
        signerContract.verifyAndConsume(stranger, 100 * 1e18, cleanupId, deadline, sig);
    }

    function test_RevertWhen_ExpiredSignature() public {
        bytes32 cleanupId = keccak256("cleanup-expired");
        uint256 deadline = block.timestamp - 1;
        bytes memory sig = _sign(stranger, 100 * 1e18, cleanupId, deadline);

        vm.expectRevert(Signer.ExpiredSignature.selector);
        signerContract.verifyAndConsume(stranger, 100 * 1e18, cleanupId, deadline, sig);
    }

    function test_RevertWhen_WrongSigner() public {
        bytes32 cleanupId = keccak256("cleanup-wrong-signer");
        uint256 deadline = block.timestamp + 1 hours;

        // Sign with wrong key
        uint256 wrongPk = 0xDEAD;
        bytes32 structHash = keccak256(
            abi.encode(
                signerContract.CLAIM_AUTHORISATION_TYPEHASH(),
                stranger,
                uint256(100 * 1e18),
                cleanupId,
                deadline
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", signerContract.domainSeparator(), structHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongPk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.expectRevert(Signer.InvalidSignature.selector);
        signerContract.verifyAndConsume(stranger, 100 * 1e18, cleanupId, deadline, sig);
    }

    function test_RevertWhen_ZeroUser() public {
        bytes32 cleanupId = keccak256("cleanup-zero-user");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(address(0), 100 * 1e18, cleanupId, deadline);

        vm.expectRevert(Signer.InvalidAddress.selector);
        signerContract.verifyAndConsume(address(0), 100 * 1e18, cleanupId, deadline, sig);
    }

    function test_IsValid_ReturnsFalse_ZeroUser() public view {
        bytes32 cleanupId = keccak256("cleanup-zero");
        bytes memory sig = hex"00";
        assertFalse(signerContract.isValid(address(0), 100, cleanupId, block.timestamp + 1, sig));
    }

    function test_IsValid_ReturnsFalse_Expired() public view {
        bytes32 cleanupId = keccak256("cleanup-exp");
        bytes memory sig = hex"00";
        assertFalse(signerContract.isValid(stranger, 100, cleanupId, block.timestamp - 1, sig));
    }

    function test_IsValid_ReturnsFalse_AfterConsume() public {
        bytes32 cleanupId = keccak256("cleanup-isvalid");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(stranger, 50 * 1e18, cleanupId, deadline);

        assertTrue(signerContract.isValid(stranger, 50 * 1e18, cleanupId, deadline, sig));
        signerContract.verifyAndConsume(stranger, 50 * 1e18, cleanupId, deadline, sig);
        assertFalse(signerContract.isValid(stranger, 50 * 1e18, cleanupId, deadline, sig));
    }

    // ── addSigner / removeSigner ──────────────────────────────────────────────

    function test_AddSigner() public {
        address newSigner = makeAddr("newSigner");

        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit Signer.SignerAdded(newSigner);
        signerContract.addSigner(newSigner);

        assertTrue(signerContract.hasRole(signerContract.SIGNER_ROLE(), newSigner));
    }

    function test_RemoveSigner() public {
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit Signer.SignerRemoved(signerAddr);
        signerContract.removeSigner(signerAddr);

        assertFalse(signerContract.hasRole(signerContract.SIGNER_ROLE(), signerAddr));
    }

    function test_RevertWhen_AddSignerZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(Signer.InvalidAddress.selector);
        signerContract.addSigner(address(0));
    }

    function test_RevertWhen_AddSignerUnauthorized() public {
        vm.prank(stranger);
        vm.expectRevert();
        signerContract.addSigner(makeAddr("x"));
    }

    // ── fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_SignAndVerify(uint256 amount, bytes32 cleanupId) public {
        vm.assume(amount > 0);
        uint256 deadline = block.timestamp + 1 days;
        bytes memory sig = _sign(stranger, amount, cleanupId, deadline);

        assertTrue(signerContract.isValid(stranger, amount, cleanupId, deadline, sig));
        signerContract.verifyAndConsume(stranger, amount, cleanupId, deadline, sig);
        assertTrue(signerContract.usedCleanupIds(cleanupId));
    }
}
