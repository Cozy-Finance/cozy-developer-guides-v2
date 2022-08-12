// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "cozy-v2-triggers/interfaces/IConfig.sol";
import "src/interfaces/ISet.sol";

/**
 * @dev Interface for interacting with the Cozy protocol Manager. This is not a comprehensive
 * interface.
 */
interface IManager is IConfig {
  /// @notice Max fee for deposit and purchase.
  /// - Protocol deposit fee for reserves + protocol deposit fee for backstop <= MAX_FEE.
  /// - Protocol purchase fee for reserves + protocol purchase fee for backstop <= MAX_FEE.
  //  - Protocol cancellation fee for reserves + protocol cancellation fee for backstop <= MAX_FEE.
  /// - Set deposit fee <= MAX_FEE.
  /// - Market purchase fee <= MAX_FEE.
  function MAX_FEE() view external returns (uint256);

  /// @notice Callable by the owner of `_set` and sends accrued fees to `_receiver`.
  function claimSetFees(ISet _set, address _receiver) external;

  /// @notice Deploys a new set with the provided parameters.
  function createSet(address owner, address pauser, address asset, SetConfig memory setConfig, MarketInfo[] memory marketInfos, bytes32 salt) external returns (ISet set);

  /// @notice Execute queued updates to set config and market configs.
  function finalizeUpdateConfigs(ISet set, SetConfig memory setConfig, MarketInfo[] memory marketInfos) external;

  /// @notice Pauses _set.
  function pause(ISet _set) external;

  /// @notice This hash is used to prove that the `SetConfig` and `MarketInfo[]` params used when applying config
  /// updates are identical to the queued updates.
  function queuedConfigUpdateHash(ISet set) view external returns (bytes32);

  /// @notice For the specified set, returns whether it's a valid Cozy set, if it's approved to use the backstop,
  /// as well as timestamps for any configuration updates that are queued.
  function sets(ISet _set) view external returns (bool exists, bool approved, uint64 configUpdateTime, uint64 configUpdateDeadline);

  /// @notice Unpauses _set.
  function unpause(ISet _set) external;

  /// @notice Signal an update to the set config and market configs. Existing queued updates are overwritten.
  function updateConfigs(ISet set, SetConfig memory setConfig, MarketInfo[] memory marketInfos) external;

  /// @notice Updates the owner of `_set` to `_owner`.
  function updateSetOwner(ISet _set, address _owner) external;

  /// @notice Updates the pauser of `_set` to `_pauser`.
  function updateSetPauser(ISet _set, address _pauser) external;
}
