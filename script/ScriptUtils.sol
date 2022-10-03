pragma solidity 0.8.15;

import "cozy-v2-interfaces/interfaces/IManager.sol";
import "forge-std/Script.sol";

contract ScriptUtils is Script {

  using stdJson for string;

  string INPUT_FOLDER = "/script/input/";

  // Returns the json string for the specified filename from `INPUT_FOLDER`.
  function readInput(string memory _fileName) internal returns (string memory) {
    string memory _root = vm.projectRoot();
    string memory _chainInputFolder = string.concat(INPUT_FOLDER, vm.toString(block.chainid), "/");
    string memory _inputFile = string.concat(_fileName, ".json");
    string memory _inputPath = string.concat(_root, _chainInputFolder, _inputFile);
    return vm.readFile(_inputPath);
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