// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ISet.sol";

/**
 * @dev Data types and events for the Manager.
 */
interface IManagerTypes is IConfig {
  /// @notice Used to update backstop approvals.
  struct BackstopApproval {
    ISet set;
    bool status;
  }

  /// @notice All delays that can be set by the Cozy admin.
  struct Delays {
    uint256 configUpdateDelay; // Duration between when a set/market configuration updates are queued and when they can be executed.
    uint256 configUpdateGracePeriod; // Defines how long the admin has to execute a configuration change, once it can be executed.
    uint256 minDepositDuration; // The minimum duration before a withdrawal can be initiated after a deposit.
    uint256 withdrawDelay; // If not paused, suppliers must queue a withdrawal and wait this long before completing the withdrawal.
    uint256 purchaseDelay; // Protection does not mature (i.e. it cannot claim funds from a trigger) until this delay elapses after purchase.
  }

  /// @notice All fees that can be set by the Cozy admin.
  struct Fees {
    uint16 depositFeeReserves;  // Fee charged on deposit and min, allocated to the protocol reserves, denoted in zoc.
    uint16 depositFeeBackstop; // Fee charged on deposit and min, allocated to the protocol backstop, denoted in zoc.
    uint16 purchaseFeeReserves; // Fee charged on purchase, allocated to the protocol reserves, denoted in zoc.
    uint16 purchaseFeeBackstop; // Fee charged on purchase, allocated to the protocol backstop, denoted in zoc.
    uint16 cancellationFeeReserves; // Fee charged on cancellation, allocated to the protocol reserves, denoted in zoc.
    uint16 cancellationFeeBackstop; // Fee charged on cancellation, allocated to the protocol backstop, denoted in zoc.
  }

  /// @notice A market or set is considered inactive when it's FROZEN or PAUSED.
  struct InactivityData {
    uint64 inactiveTransitionTime; // The timestamp the set/market transitioned from active to inactive, if currently inactive. 0 otherwise.
    InactivePeriod[] periods; // Array of all inactive periods for a set or market.
  }

  /// @notice Set related data.
  struct SetData {
    // When a set is created, this is updated to true.
    bool exists;
     // If true, this set can use funds from the backstop.
    bool approved;
    // Earliest timestamp at which finalizeUpdateConfigs can be called to apply config updates queued by updateConfigs.
    uint64 configUpdateTime;
    // Maps from set address to the latest timestamp after configUpdateTime at which finalizeUpdateConfigs can be
    // called to apply config updates queued by updateConfigs. After this timestamp, the queued config updates
    // expire and can no longer be applied.
    uint64 configUpdateDeadline;
  }
}
