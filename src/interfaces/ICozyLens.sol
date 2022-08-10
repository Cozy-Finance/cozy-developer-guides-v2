// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ISet.sol";

/**
 * @dev Interface for interacting with the Cozy Lens. This is not a comprehensive
 * interface.
 */
interface ICozyLens is IConfig {
  /// @notice Returns the set configUpdateTime.
  function getConfigUpdateDeadline(ISet set) view external returns (uint256 configUpdateDeadline);

  /// @notice Returns the sets configUpdateDeadline.
  function getConfigUpdateTime(ISet set) view external returns (uint256 configUpdateTime);

  /// @notice Returns the `MarketInfo` for the market, identified by its `_set` and `_trigger` address.
  function getMarketInfo(ISet set, address trigger) external view returns (MarketInfo memory);

  /// @notice Returns the `SetConfig` for the `_set`.
  function getSetConfig(ISet set) external view returns (SetConfig memory);
}
