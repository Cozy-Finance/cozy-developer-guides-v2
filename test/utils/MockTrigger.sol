// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

import "src/FlexibleTrigger.sol";
import "src/interfaces/IManager.sol";

// A mock trigger that allows anyone to change what the programmaticCheck returns. See FlexibleTrigger for more details.
contract MockTrigger is FlexibleTrigger {
  bool internal _programmaticCheckResponse;
  constructor(
    IManager _manager,
    address _boss,
    address[] memory _freezers,
    bool _autoTrigger,
    uint256 _maxFreezeDuration
  ) FlexibleTrigger(_manager, _boss, _freezers, _autoTrigger, _maxFreezeDuration) {}

  function programmaticCheck() internal override view returns (bool) {
    return _programmaticCheckResponse;
  }

  // Anyone can call this method to update the return value of programmaticCheck.
  function updateProgrammaticCheckResponse(bool _response) public {
    _programmaticCheckResponse = _response;
  }
}
