// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { Vesting } from "../src/Vesting.sol";
import { ECOD } from "../src/ECOD.sol";

contract VestingTest is Test {
    Vesting public vesting;
    ECOD public ecod;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public stranger = makeAddr("stranger");

    uint256 public constant TOTAL = 1_000_000 * 1e18;
    uint256 public constant CLIFF = 182 days;
    uint256 public constant DURATION = 548 days;

    // ── setup ─────────────────────────────────────────────────────────────────

    function setUp() public {
        vm.startPrank(admin);
        ecod = new ECOD(admin, admin, admin, admin, admin, admin, admin);
        vesting = new Vesting(admin, address(ecod));
        ecod.approve(address(vesting), type(uint256).max);
        vm.stopPrank();
    }

    // ── constructor ───────────────────────────────────────────────────────────

    function test_Constructor() public view {
        assertEq(address(vesting.TOKEN()), address(ecod));
        assertTrue(vesting.hasRole(vesting.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_RevertWhen_ZeroAddressConstructor() public {
        vm.expectRevert(Vesting.InvalidAddress.selector);
        new Vesting(address(0), address(ecod));

        vm.expectRevert(Vesting.InvalidAddress.selector);
        new Vesting(admin, address(0));
    }

    // ── createSchedule ────────────────────────────────────────────────────────

    function test_CreateSchedule() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vm.expectEmit(true, true, false, true);
        emit Vesting.ScheduleCreated(0, alice, TOTAL, start, CLIFF, DURATION);
        uint256 id = vesting.createSchedule(alice, TOTAL, start, false);

        assertEq(id, 0);
        assertEq(vesting.schedulesCount(), 1);

        (
            address beneficiary,
            uint256 totalAmount,
            uint256 released,
            uint256 startTime,
            ,
            ,
            bool revocable,
            bool revoked
        ) = vesting.schedules(0);

        assertEq(beneficiary, alice);
        assertEq(totalAmount, TOTAL);
        assertEq(released, 0);
        assertEq(startTime, start);
        assertFalse(revocable);
        assertFalse(revoked);
        assertEq(ecod.balanceOf(address(vesting)), TOTAL);
    }

    function test_RevertWhen_CreateSchedule_ZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(Vesting.InvalidAddress.selector);
        vesting.createSchedule(address(0), TOTAL, block.timestamp, false);
    }

    function test_RevertWhen_CreateSchedule_ZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(Vesting.InvalidAmount.selector);
        vesting.createSchedule(alice, 0, block.timestamp, false);
    }

    function test_RevertWhen_CreateSchedule_ZeroStart() public {
        vm.prank(admin);
        vm.expectRevert(Vesting.InvalidSchedule.selector);
        vesting.createSchedule(alice, TOTAL, 0, false);
    }

    function test_RevertWhen_CreateSchedule_Unauthorized() public {
        vm.prank(stranger);
        vm.expectRevert();
        vesting.createSchedule(alice, TOTAL, block.timestamp, false);
    }

    // ── cliff ─────────────────────────────────────────────────────────────────

    function test_NoTokensBeforeCliff() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        // Just before cliff
        vm.warp(start + CLIFF - 1);
        assertEq(vesting.releasable(0), 0);
        assertEq(vesting.vested(0), 0);
    }

    function test_NothingToRelease_BeforeCliff() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + CLIFF - 1);
        vm.prank(alice);
        vm.expectRevert(Vesting.NothingToRelease.selector);
        vesting.release(0);
    }

    // ── linear vesting ────────────────────────────────────────────────────────

    function test_LinearVesting_AtCliff() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + CLIFF);
        uint256 expected = (TOTAL * CLIFF) / DURATION;
        assertApproxEqAbs(vesting.releasable(0), expected, 1e15);
    }

    function test_LinearVesting_AtHalfway() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION / 2);
        uint256 expected = TOTAL / 2;
        assertApproxEqAbs(vesting.releasable(0), expected, 1e15);
    }

    function test_FullyVested_AfterDuration() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION);
        assertEq(vesting.releasable(0), TOTAL);
        assertEq(vesting.vested(0), TOTAL);
    }

    function test_FullyVested_AfterDurationPlusExtra() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION + 365 days);
        assertEq(vesting.releasable(0), TOTAL);
    }

    // ── release ───────────────────────────────────────────────────────────────

    function test_Release_AtHalfway() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION / 2);
        uint256 releasableAmt = vesting.releasable(0);

        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Vesting.Released(0, alice, releasableAmt);
        vesting.release(0);

        assertEq(ecod.balanceOf(alice), releasableAmt);
        assertEq(vesting.releasable(0), 0); // nothing more releasable immediately
    }

    function test_Release_FullAmount() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION);

        vm.prank(alice);
        vesting.release(0);

        assertEq(ecod.balanceOf(alice), TOTAL);
        assertEq(ecod.balanceOf(address(vesting)), 0);
    }

    function test_Release_CanBeCalledByAnyone() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        vm.warp(start + DURATION);

        // Stranger calls release — tokens go to alice
        vm.prank(stranger);
        vesting.release(0);

        assertEq(ecod.balanceOf(alice), TOTAL);
        assertEq(ecod.balanceOf(stranger), 0);
    }

    function test_RevertWhen_ScheduleNotFound() public {
        vm.expectRevert(Vesting.ScheduleNotFound.selector);
        vesting.releasable(99);

        vm.expectRevert(Vesting.ScheduleNotFound.selector);
        vesting.release(99);
    }

    // ── revoke ────────────────────────────────────────────────────────────────

    function test_RevokeSchedule_Halfway() public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, true);

        vm.warp(start + DURATION / 2);
        uint256 vestedHalf = (TOTAL * (DURATION / 2)) / DURATION;

        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit Vesting.ScheduleRevoked(0, TOTAL - vestedHalf);
        vesting.revokeSchedule(0);

        // Alice should have received vested portion
        assertApproxEqAbs(ecod.balanceOf(alice), vestedHalf, 1e15);
        // Admin should have received unvested portion
        // (admin had initial supply minus TOTAL transferred to vesting)
    }

    function test_RevertWhen_RevokeNonRevocable() public {
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, block.timestamp, false);

        vm.prank(admin);
        vm.expectRevert(Vesting.InvalidSchedule.selector);
        vesting.revokeSchedule(0);
    }

    function test_RevertWhen_RevokeAlreadyRevoked() public {
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, block.timestamp, true);

        vm.warp(block.timestamp + CLIFF);

        vm.prank(admin);
        vesting.revokeSchedule(0);

        vm.prank(admin);
        vm.expectRevert(Vesting.InvalidSchedule.selector);
        vesting.revokeSchedule(0);
    }

    function test_RevertWhen_ReleaseAfterRevoke() public {
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, block.timestamp, true);

        vm.warp(block.timestamp + CLIFF);

        vm.prank(admin);
        vesting.revokeSchedule(0);

        vm.prank(alice);
        vm.expectRevert(Vesting.InvalidSchedule.selector);
        vesting.release(0);
    }

    function test_RevertWhen_RevokeUnauthorized() public {
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, block.timestamp, true);

        vm.prank(stranger);
        vm.expectRevert();
        vesting.revokeSchedule(0);
    }

    // ── multiple schedules ────────────────────────────────────────────────────

    function test_MultipleSchedules() public {
        uint256 start = block.timestamp;
        uint256 aliceAmount = 600_000 * 1e18;
        uint256 bobAmount = 400_000 * 1e18;

        vm.startPrank(admin);
        vesting.createSchedule(alice, aliceAmount, start, false);
        vesting.createSchedule(bob, bobAmount, start, true);
        vm.stopPrank();

        assertEq(vesting.schedulesCount(), 2);

        vm.warp(start + DURATION);

        vm.prank(alice);
        vesting.release(0);
        assertEq(ecod.balanceOf(alice), aliceAmount);

        vm.prank(bob);
        vesting.release(1);
        assertEq(ecod.balanceOf(bob), bobAmount);
    }

    // ── fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_LinearVesting(uint256 timeElapsed) public {
        uint256 start = block.timestamp;
        vm.prank(admin);
        vesting.createSchedule(alice, TOTAL, start, false);

        timeElapsed = bound(timeElapsed, CLIFF, DURATION);
        vm.warp(start + timeElapsed);

        uint256 expectedVested = (TOTAL * timeElapsed) / DURATION;
        assertApproxEqAbs(vesting.vested(0), expectedVested, 1e15);
    }
}
