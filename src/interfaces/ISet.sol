// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/ICState.sol";

/**
 * @dev Interface for interacting with Cozy protocol Sets. This is not a comprehensive
 * interface.
 */
interface ISet is ICState {
  /// @notice Returns the state of the market or set. Pass a market address to read that market's state, or the set's
  /// address to read the set's state.
  function state(address who) view external returns (CState state);
}
