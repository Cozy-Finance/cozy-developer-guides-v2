// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ISet.sol";

/**
 * @notice Interface for the Cozy Manager.
 */
interface IManager is IConfig {
  /// @notice Deploys a new set with the provided parameters.
  function createSet(address _owner, address _pauser, address _asset, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos, bytes32 _salt) external returns (ISet _set);
}
