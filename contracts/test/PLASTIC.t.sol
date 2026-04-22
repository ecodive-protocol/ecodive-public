// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PLASTIC} from "../src/PLASTIC.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract PLASTICTest is Test {
    PLASTIC internal plastic;

    address internal admin = makeAddr("admin");
    address internal treasury = makeAddr("treasury");
    address internal corp = makeAddr("corporation");

    bytes32 internal constant CLEANUP_ID = keccak256("cleanup-baltic-001");

    function setUp() public {
        plastic = new PLASTIC(admin);
    }

    // ============ Constructor ============

    function test_InitialState() public view {
        assertEq(plastic.name(), "EcoDive Plastic Credit");
        assertEq(plastic.symbol(), "PLASTIC");
        assertEq(plastic.totalSupply(), 0);
        assertEq(plastic.totalKgMinted(), 0);
        assertEq(plastic.totalKgBurned(), 0);
        assertTrue(plastic.hasRole(plastic.MINTER_ROLE(), admin));
    }

    function test_RevertWhen_ZeroAdmin() public {
        vm.expectRevert(PLASTIC.InvalidAddress.selector);
        new PLASTIC(address(0));
    }

    // ============ Minting ============

    function test_MintCleanup() public {
        vm.prank(admin);
        plastic.mintCleanup(treasury, 5 * 1e18, CLEANUP_ID);

        assertEq(plastic.balanceOf(treasury), 5 * 1e18);
        assertEq(plastic.totalKgMinted(), 5 * 1e18);
    }

    function test_MintCleanup_EmitsEvent() public {
        vm.prank(admin);
        vm.expectEmit(true, true, true, true);
        emit PLASTIC.CleanupMinted(treasury, 5 * 1e18, CLEANUP_ID);
        plastic.mintCleanup(treasury, 5 * 1e18, CLEANUP_ID);
    }

    function test_RevertWhen_MintByNonMinter() public {
        bytes32 minterRole = plastic.MINTER_ROLE();
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, corp, minterRole)
        );
        vm.prank(corp);
        plastic.mintCleanup(treasury, 1e18, CLEANUP_ID);
    }

    function test_RevertWhen_MintToZero() public {
        vm.prank(admin);
        vm.expectRevert(PLASTIC.InvalidAddress.selector);
        plastic.mintCleanup(address(0), 1e18, CLEANUP_ID);
    }

    function test_RevertWhen_MintZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(PLASTIC.InvalidAmount.selector);
        plastic.mintCleanup(treasury, 0, CLEANUP_ID);
    }

    // ============ Burning with certificate ============

    function test_BurnWithCertificate() public {
        vm.prank(admin);
        plastic.mintCleanup(corp, 1000 * 1e18, CLEANUP_ID);

        bytes memory metadata = abi.encode("Zywiec Zdroj 2026 Q3");

        vm.prank(corp);
        bytes32 certId = plastic.burnWithCertificate(500 * 1e18, metadata);

        assertEq(plastic.balanceOf(corp), 500 * 1e18);
        assertEq(plastic.totalKgBurned(), 500 * 1e18);
        assertTrue(certId != bytes32(0));
    }

    function test_BurnWithCertificate_EmitsEvent() public {
        vm.prank(admin);
        plastic.mintCleanup(corp, 1000 * 1e18, CLEANUP_ID);

        bytes memory metadata = abi.encode("test-corp");

        vm.prank(corp);
        vm.recordLogs();
        plastic.burnWithCertificate(100 * 1e18, metadata);

        // At least the BurnCertificate event should be emitted
        assertTrue(vm.getRecordedLogs().length >= 1);
    }

    function test_RevertWhen_BurnZero() public {
        vm.prank(corp);
        vm.expectRevert(PLASTIC.InvalidAmount.selector);
        plastic.burnWithCertificate(0, "");
    }

    function test_RevertWhen_MetadataTooLong() public {
        vm.prank(admin);
        plastic.mintCleanup(corp, 1000 * 1e18, CLEANUP_ID);

        bytes memory tooLong = new bytes(257);

        vm.prank(corp);
        vm.expectRevert(PLASTIC.CertificateMetadataTooLong.selector);
        plastic.burnWithCertificate(1e18, tooLong);
    }

    function test_RevertWhen_BurnExceedsBalance() public {
        vm.prank(corp);
        vm.expectRevert();
        plastic.burnWithCertificate(1e18, "");
    }

    // ============ Fuzz ============

    function testFuzz_MintAndBurn(uint256 mintAmount, uint256 burnAmount) public {
        mintAmount = bound(mintAmount, 1, 1_000_000_000 * 1e18);
        burnAmount = bound(burnAmount, 1, mintAmount);

        vm.prank(admin);
        plastic.mintCleanup(corp, mintAmount, CLEANUP_ID);

        vm.prank(corp);
        plastic.burnWithCertificate(burnAmount, "");

        assertEq(plastic.balanceOf(corp), mintAmount - burnAmount);
        assertEq(plastic.totalKgMinted(), mintAmount);
        assertEq(plastic.totalKgBurned(), burnAmount);
    }
}
