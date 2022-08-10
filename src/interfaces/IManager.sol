// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ISet.sol";

/**
 * @dev Interface for interacting with the Cozy protocol Manager. This is not a comprehensive
 * interface.
 */
interface IManager is IConfig {
  /// @notice Deploys a new set with the provided parameters.
  function createSet(address owner, address pauser, address asset, SetConfig memory setConfig, MarketInfo[] memory marketInfos, bytes32 salt) external returns (ISet set);

  /// @notice Execute queued updates to set config and market configs.
  function finalizeUpdateConfigs(ISet set, SetConfig memory setConfig, MarketInfo[] memory marketInfos) external;

  /// @notice This hash is used to prove that the `SetConfig` and `MarketInfo[]` params used when applying config
  /// updates are identical to the queued updates.
  function queuedConfigUpdateHash(ISet set) view external returns (bytes32);

  /// @notice Signal an update to the set config and market configs. Existing queued updates are overwritten.
  function updateConfigs(ISet set, SetConfig memory setConfig, MarketInfo[] memory marketInfos) external;
}
