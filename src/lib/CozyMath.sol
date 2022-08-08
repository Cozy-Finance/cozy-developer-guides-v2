// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

/**
 * @dev Helper methods for common math operations.
 */
library CozyMath {
  /// @dev Performs `x * y` without overflow checks. Only use this when you are sure `x * y` will not overflow.
  function unsafemul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    assembly { z := mul(x, y) }
  }

  /// @dev Unchecked increment of the provided value. Realistically it's impossible to overflow a uint256 so this is
  /// always safe.
  function uncheckedIncrement(uint256 i) internal pure returns (uint256) {
    unchecked { return i + 1; }
  }

  /// @dev Performs `x / y` without divide by zero checks. Only use this when you are sure `y` is not zero.
  function unsafediv(uint256 x, uint256 y) internal pure returns (uint256 z) {
    // Only use this when you are sure y is not zero.
    assembly { z := div(x, y) }
  }

  /// @dev Returns `x - y` if the result is positive, or zero if `x - y` would overflow and result in a negative value.
  /// @dev Named doz as shorthand for difference or zero, see https://en.wikipedia.org/wiki/Monus#Natural_numbers.
  function doz(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked { z = x >=y ? x - y : 0; }
  }
}
