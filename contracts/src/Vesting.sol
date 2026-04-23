// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Vesting — 18-month linear vesting for team allocation
/// @notice Tokens vest linearly from `startTime` over 18 months (548 days).
///         A 6-month cliff applies: no tokens can be claimed before the cliff.
/// @dev Admin can create multiple vesting schedules (for different team members).
///      Beneficiary calls `release()` to withdraw vested tokens at any time after cliff.
contract Vesting is AccessControl {
    using SafeERC20 for IERC20;

    // ============ Errors ============

    error InvalidAddress();
    error InvalidAmount();
    error InvalidSchedule();
    error NothingToRelease();
    error ScheduleNotFound();

    // ============ Events ============

    event ScheduleCreated(
        uint256 indexed scheduleId,
        address indexed beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration
    );
    event Released(uint256 indexed scheduleId, address indexed beneficiary, uint256 amount);
    event ScheduleRevoked(uint256 indexed scheduleId, uint256 unvestedReturned);

    // ============ Constants ============

    /// @notice 18-month vesting duration in seconds (18 × 30.44 days × 86400 s)
    uint256 public constant VESTING_DURATION = 548 days;

    /// @notice 6-month cliff duration in seconds
    uint256 public constant CLIFF_DURATION = 182 days;

    // ============ Types ============

    struct Schedule {
        address beneficiary;
        uint256 totalAmount;
        uint256 released;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 vestingDuration;
        bool revocable;
        bool revoked;
    }

    // ============ State ============

    IERC20 public immutable TOKEN;

    Schedule[] public schedules;

    // ============ Constructor ============

    /// @param admin      Account receiving DEFAULT_ADMIN_ROLE
    /// @param ecodToken  ECOD token address
    constructor(address admin, address ecodToken) {
        if (admin == address(0) || ecodToken == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        TOKEN = IERC20(ecodToken);
    }

    // ============ Admin ============

    /// @notice Create a new vesting schedule and lock tokens in the contract.
    /// @param beneficiary    The account that will receive vested tokens.
    /// @param totalAmount    Total tokens to vest (must be pre-approved or transferred).
    /// @param startTime      Unix timestamp when vesting starts (can be in the past for retroactive).
    /// @param revocable      Whether admin can revoke unvested tokens.
    function createSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        bool revocable
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 scheduleId) {
        if (beneficiary == address(0)) revert InvalidAddress();
        if (totalAmount == 0) revert InvalidAmount();
        if (startTime == 0) revert InvalidSchedule();

        scheduleId = schedules.length;
        schedules.push(
            Schedule({
                beneficiary: beneficiary,
                totalAmount: totalAmount,
                released: 0,
                startTime: startTime,
                cliffDuration: CLIFF_DURATION,
                vestingDuration: VESTING_DURATION,
                revocable: revocable,
                revoked: false
            })
        );

        TOKEN.safeTransferFrom(msg.sender, address(this), totalAmount);

        emit ScheduleCreated(
            scheduleId, beneficiary, totalAmount, startTime, CLIFF_DURATION, VESTING_DURATION
        );
    }

    /// @notice Revoke a revocable schedule — unvested tokens return to admin.
    function revokeSchedule(uint256 scheduleId)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        Schedule storage s = _getSchedule(scheduleId);
        if (!s.revocable) revert InvalidSchedule();
        if (s.revoked) revert InvalidSchedule();

        uint256 vestedAmt = _vestedAmount(s);
        uint256 releasableAmt = vestedAmt - s.released;
        uint256 unvested = s.totalAmount - vestedAmt;

        s.revoked = true;

        // Pay out any already-vested but unclaimed tokens to beneficiary
        if (releasableAmt > 0) {
            s.released += releasableAmt;
            TOKEN.safeTransfer(s.beneficiary, releasableAmt);
        }

        // Return unvested to admin
        if (unvested > 0) {
            TOKEN.safeTransfer(msg.sender, unvested);
        }

        emit ScheduleRevoked(scheduleId, unvested);
    }

    // ============ Beneficiary ============

    /// @notice Release all vested but unreleased tokens for a schedule.
    /// @dev Can be called by anyone on behalf of the beneficiary — tokens always go to beneficiary.
    function release(uint256 scheduleId) external {
        Schedule storage s = _getSchedule(scheduleId);
        if (s.revoked) revert InvalidSchedule();

        uint256 releasableAmt = _vestedAmount(s) - s.released;
        if (releasableAmt == 0) revert NothingToRelease();

        s.released += releasableAmt;
        TOKEN.safeTransfer(s.beneficiary, releasableAmt);

        emit Released(scheduleId, s.beneficiary, releasableAmt);
    }

    // ============ View ============

    /// @notice Returns the total number of schedules.
    function schedulesCount() external view returns (uint256) {
        return schedules.length;
    }

    /// @notice Returns how many tokens are currently releasable for a schedule.
    function releasable(uint256 scheduleId) external view returns (uint256) {
        Schedule storage s = _getSchedule(scheduleId);
        if (s.revoked) return 0;
        return _vestedAmount(s) - s.released;
    }

    /// @notice Returns total vested amount (including already released) at current timestamp.
    function vested(uint256 scheduleId) external view returns (uint256) {
        return _vestedAmount(_getSchedule(scheduleId));
    }

    // ============ Internal ============

    function _getSchedule(uint256 scheduleId) internal view returns (Schedule storage) {
        if (scheduleId >= schedules.length) revert ScheduleNotFound();
        return schedules[scheduleId];
    }

    function _vestedAmount(Schedule storage s) internal view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        uint256 elapsed = block.timestamp - s.startTime;

        // Before cliff: nothing vested
        if (elapsed < s.cliffDuration) return 0;

        // After full vesting: everything vested
        if (elapsed >= s.vestingDuration) return s.totalAmount;

        // Linear vesting between cliff and end
        return (s.totalAmount * elapsed) / s.vestingDuration;
    }
}
