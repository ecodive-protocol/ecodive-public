// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { ECOD } from "../src/ECOD.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

contract ECODTest is Test {
    ECOD internal ecod;

    address internal admin = makeAddr("admin");
    address internal liquidity = makeAddr("liquidity");
    address internal treasury = makeAddr("treasury");
    address internal presale = makeAddr("presale");
    address internal team = makeAddr("team");
    address internal marketing = makeAddr("marketing");
    address internal dev = makeAddr("dev");

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal mockPair = makeAddr("mockPair");

    function setUp() public {
        ecod = new ECOD(admin, liquidity, treasury, presale, team, marketing, dev);
    }

    // ============ Distribution ============

    function test_InitialDistribution() public view {
        assertEq(ecod.totalSupply(), 100_000_000 * 1e18);
        assertEq(ecod.balanceOf(liquidity), 40_000_000 * 1e18);
        assertEq(ecod.balanceOf(treasury), 30_000_000 * 1e18);
        assertEq(ecod.balanceOf(presale), 15_000_000 * 1e18);
        assertEq(ecod.balanceOf(team), 10_000_000 * 1e18);
        assertEq(ecod.balanceOf(marketing), 5_000_000 * 1e18);
    }

    function test_RevertWhen_ZeroAddressInConstructor() public {
        vm.expectRevert(ECOD.InvalidWallet.selector);
        new ECOD(address(0), liquidity, treasury, presale, team, marketing, dev);
    }

    // ============ Transfers without tax ============

    function test_TransferWalletToWallet_NoTax() public {
        vm.prank(marketing);
        ecod.transfer(alice, 1000 * 1e18);

        vm.prank(alice);
        ecod.transfer(bob, 500 * 1e18);

        assertEq(ecod.balanceOf(bob), 500 * 1e18);
        assertEq(ecod.balanceOf(alice), 500 * 1e18);
    }

    // ============ Tax on DEX transfers ============

    function test_TaxApplied_WhenBuyingFromPair() public {
        vm.prank(admin);
        ecod.setTaxedPair(mockPair, true);

        // Pair gets initial balance (simulating liquidity provision)
        vm.prank(liquidity);
        ecod.transfer(mockPair, 1_000_000 * 1e18);

        uint256 treasuryBefore = ecod.balanceOf(treasury);
        uint256 liquidityBefore = ecod.balanceOf(liquidity);
        uint256 devBefore = ecod.balanceOf(dev);

        // Simulate user buying from pair (pair -> alice)
        vm.prank(mockPair);
        ecod.transfer(alice, 1000 * 1e18);

        // 3% tax: 1% treasury, 1% liquidity, 1% dev
        assertEq(ecod.balanceOf(treasury) - treasuryBefore, 10 * 1e18);
        assertEq(ecod.balanceOf(liquidity) - liquidityBefore, 10 * 1e18);
        assertEq(ecod.balanceOf(dev) - devBefore, 10 * 1e18);
        assertEq(ecod.balanceOf(alice), 970 * 1e18);
    }

    function test_TaxApplied_WhenSellingToPair() public {
        vm.prank(admin);
        ecod.setTaxedPair(mockPair, true);

        vm.prank(marketing);
        ecod.transfer(alice, 10_000 * 1e18);

        uint256 treasuryBefore = ecod.balanceOf(treasury);

        vm.prank(alice);
        ecod.transfer(mockPair, 1000 * 1e18);

        assertEq(ecod.balanceOf(treasury) - treasuryBefore, 10 * 1e18);
        assertEq(ecod.balanceOf(mockPair), 970 * 1e18);
    }

    function test_NoTax_WhenExcludedAccountTradesWithPair() public {
        vm.prank(admin);
        ecod.setTaxedPair(mockPair, true);

        // Liquidity wallet is excluded by default — transfers to pair are not taxed
        uint256 treasuryBefore = ecod.balanceOf(treasury);

        vm.prank(liquidity);
        ecod.transfer(mockPair, 1000 * 1e18);

        assertEq(ecod.balanceOf(treasury), treasuryBefore);
        assertEq(ecod.balanceOf(mockPair), 1000 * 1e18);
    }

    // ============ Admin ============

    function test_SetTaxedPair_OnlyAdmin() public {
        bytes32 adminRole = ecod.ADMIN_ROLE();
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, alice, adminRole
            )
        );
        vm.prank(alice);
        ecod.setTaxedPair(mockPair, true);
    }

    function test_SetTaxWallets() public {
        address newTreasury = makeAddr("newTreasury");
        address newLiquidity = makeAddr("newLiquidity");
        address newDev = makeAddr("newDev");

        vm.prank(admin);
        ecod.setTaxWallets(newTreasury, newLiquidity, newDev);

        assertEq(ecod.treasuryWallet(), newTreasury);
        assertEq(ecod.liquidityWallet(), newLiquidity);
        assertEq(ecod.devWallet(), newDev);
    }

    function test_RevertWhen_SetTaxWallets_ZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(ECOD.InvalidWallet.selector);
        ecod.setTaxWallets(address(0), liquidity, dev);
    }

    function test_SetExcludedFromTax() public {
        vm.prank(admin);
        ecod.setExcludedFromTax(alice, true);
        assertTrue(ecod.isExcludedFromTax(alice));

        vm.prank(admin);
        ecod.setExcludedFromTax(alice, false);
        assertFalse(ecod.isExcludedFromTax(alice));
    }

    function test_RevertWhen_SetExcludedFromTax_ZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(ECOD.InvalidWallet.selector);
        ecod.setExcludedFromTax(address(0), true);
    }

    function test_RevertWhen_SetExcludedFromTax_AlreadyExcluded() public {
        vm.prank(admin);
        vm.expectRevert(ECOD.AlreadyExcluded.selector);
        ecod.setExcludedFromTax(treasury, true); // treasury excluded in constructor
    }

    function test_RevertWhen_SetExcludedFromTax_NotExcluded() public {
        vm.prank(admin);
        vm.expectRevert(ECOD.NotExcluded.selector);
        ecod.setExcludedFromTax(alice, false);
    }

    function test_RevertWhen_SetTaxedPair_ZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(ECOD.InvalidWallet.selector);
        ecod.setTaxedPair(address(0), true);
    }

    // ============ Fuzz ============

    function testFuzz_TaxCalculation(uint256 amount) public {
        amount = bound(amount, 10_000, 1_000_000 * 1e18);

        vm.prank(admin);
        ecod.setTaxedPair(mockPair, true);

        vm.prank(liquidity);
        ecod.transfer(mockPair, amount);

        vm.prank(mockPair);
        ecod.transfer(alice, amount);

        uint256 expectedTreasury = (amount * 100) / 10_000;
        uint256 expectedLiquidity = (amount * 100) / 10_000;
        uint256 expectedDev = (amount * 100) / 10_000;
        uint256 expectedUser = amount - expectedTreasury - expectedLiquidity - expectedDev;

        assertEq(ecod.balanceOf(alice), expectedUser);
    }
}
