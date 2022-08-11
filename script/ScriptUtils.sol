pragma solidity 0.8.15;

import "src/interfaces/IConfig.sol";

contract ScriptUtils {

  // Implementation reference https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d.
  function _sortMarketInfoArray(IConfig.MarketInfo[] memory _marketInfos) internal pure returns(IConfig.MarketInfo[] memory) {
    // Copy the _marketInfos array.
    IConfig.MarketInfo[] memory _sortedMarketInfos = new IConfig.MarketInfo[](_marketInfos.length);
    for (uint256 i = 0; i < _sortedMarketInfos.length; i++) {
      _sortedMarketInfos[i] = _marketInfos[i];
    }

    // Quicksort the copied array.
    if (_sortedMarketInfos.length > 1) {
      _quickSort(_sortedMarketInfos, 0, _sortedMarketInfos.length - 1);
    }
    return _sortedMarketInfos;
  }

  function _quickSort(IConfig.MarketInfo[] memory _marketInfos, uint256 low, uint256 high) internal pure {
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