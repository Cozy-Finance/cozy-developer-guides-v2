// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/ICState.sol";
import "src/interfaces/IERC20.sol";
import "src/interfaces/IManagerTypes.sol";

/**
 * @dev Data types and events for the Manager.
 */
interface IManagerEvents is ICState, IManagerTypes {
  /// @dev Emitted when a new set is given permission to pull funds from the backstop if it has a shortfall after a trigger.
  event BackstopApprovalStatusUpdated(address indexed set, bool status);

  /// @dev Emitted when the Cozy configuration delays are updated, and when a set is created.
  event ConfigParamsUpdated(uint256 configUpdateDelay, uint256 configUpdateGracePeriod);

  /// @dev Emitted when a Set admin's queued set and market configuration updates are applied, and when a set is created.
  event ConfigUpdatesFinalized(address indexed set, SetConfig setConfig, MarketInfo[] marketInfos);

  /// @dev Emitted when a Set admin queues new set and/or market configurations.
  event ConfigUpdatesQueued(address indexed set, SetConfig setConfig, MarketInfo[] marketInfos, uint256 updateTime, uint256 updateDeadline);

  /// @dev Emitted when accrued Cozy reserve fees and backstop fees are swept from a Set to the Cozy admin (for reserves) and backstop.
  event CozyFeesClaimed(address indexed set);

  /// @dev Emitted when the delays affecting user actions are initialized or updated by the Cozy admin.
  event DelaysUpdated(uint256 minDepositDuration, uint256 withdrawDelay, uint256 purchaseDelay);

  /// @dev Emitted when the deposit cap for an asset is updated by the Cozy admin.
  event DepositCapUpdated(IERC20 indexed asset, uint256 depositCap);

  /// @dev Emitted when the Cozy protocol fees are updated by the Cozy admin.
  /// Changes to fees for the Set admin are emitted in ConfigUpdatesQueued and ConfigUpdatesFinalized.
  event FeesUpdated(Fees fees);

  /// @dev Emitted when a market, defined by it's trigger address, changes state.
  event MarketStateUpdated(address indexed set, address indexed trigger, CState indexed state);

  /// @dev Emitted when the admin of a set is updated.
  event SetAdminUpdated(address indexed set, address indexed admin);

  /// @dev Emitted when the Set admin claims their portion of fees.
  event SetFeesClaimed(address indexed set, address _receiver);

  /// @dev Emitted when the Set's pauser is updated.
  event SetPauserUpdated(address indexed set, address indexed pauser);

  /// @dev Emitted when the Set's state is updated.
  event SetStateUpdated(address indexed set, CState indexed state);
}
