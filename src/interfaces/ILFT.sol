// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IERC20.sol";

/**
 * @dev Interface for LFT tokens.
 */
interface ILFT is IERC20 {
  /// @notice Data saved off on each mint.
  struct MintMetadata {
    uint128 amount; // Amount of tokens minted.
    uint64 time; // Timestamp of the mint.
    uint64 delay; // Delay until these tokens mature and become fungible.
  }
}