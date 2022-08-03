// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

import "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/Test.sol";
import "src/interfaces/IBaseTrigger.sol";
import "src/interfaces/ICState.sol";

// Extends DSPlus with additional helper methods.
contract DSTestPlus is Test {
  using stdStorage for StdStorage;

  function assertEq(ICState.CState a, ICState.CState b) internal {
    if (a != b) {
      emit log("Error: a == b not satisfied [ICState.CState]");
      emit log_named_uint("  Expected", uint256(b));
      emit log_named_uint("    Actual", uint256(a));
      fail();
    }
  }

  function assertEq(IBaseTrigger a, IBaseTrigger b) internal {
    assertEq(address(a), address(b));
  }

  function assertNotEq(IBaseTrigger a, IBaseTrigger b) internal {
    assertNotEq(address(a), address(b));
  }

  function assertEq(AggregatorV3Interface a, AggregatorV3Interface b) internal {
    assertEq(address(a), address(b));
  }

  function assertNotEq(AggregatorV3Interface a, AggregatorV3Interface b) internal {
    assertNotEq(address(a), address(b));
  }

  function assertNotEq(address a, address b) internal {
    if (a == b) {
      emit log("Error: a != b not satisfied [Address]");
      emit log_named_address("    Both values", a);
      fail();
    }
  }
}
