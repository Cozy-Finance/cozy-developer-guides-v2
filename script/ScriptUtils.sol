pragma solidity 0.8.15;

import "forge-std/Script.sol";
import "cozy-v2-interfaces/interfaces/IManager.sol";

contract ScriptUtils is Script {

  string constant PRIVATE_KEY = "PRIVATE_KEY";

  // The private key in your .env used for script transactions, assigned in run().
  uint256 privateKey;

  function loadDeployerKey() internal {
    privateKey = vm.envUint(PRIVATE_KEY);
    console2.log("Account used for transactions", vm.addr(privateKey));
    console2.log("====================");
  }

  // Implementation reference https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d.
  function _sortMarketInfoArray(MarketInfo[] memory _marketInfos) internal pure returns(MarketInfo[] memory) {
    // Copy the _marketInfos array.
    MarketInfo[] memory _sortedMarketInfos = new MarketInfo[](_marketInfos.length);
    for (uint256 i = 0; i < _sortedMarketInfos.length; i++) {
      _sortedMarketInfos[i] = _marketInfos[i];
    }

    // Quicksort the copied array.
    if (_sortedMarketInfos.length > 1) {
      _quickSort(_sortedMarketInfos, 0, _sortedMarketInfos.length - 1);
    }
    return _sortedMarketInfos;
  }

  function _quickSort(MarketInfo[] memory _marketInfos, uint256 low, uint256 high) internal pure {
    if (low < high) {
      address pivotVal = _marketInfos[(low + high) / 2].trigger;

      uint256 low1 = low;
      uint256 high1 = high;
      for (;;) {
        while (_marketInfos[low1].trigger < pivotVal) low1++;
        while (_marketInfos[high1].trigger > pivotVal) high1--;
        if (low1 >= high1) break;
        (_marketInfos[low1], _marketInfos[high1]) = (_marketInfos[high1], _marketInfos[low1]);
        low1++;
        high1--;
      }
      if (low < high1) _quickSort(_marketInfos, low, high1);
      high1++;
      if (high1 < high) _quickSort(_marketInfos, high1, high);
    }
  }
}