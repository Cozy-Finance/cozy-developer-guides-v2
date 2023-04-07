// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ISet} from "script/interfaces/ISet.sol";
import {ConfigUpdateMetadata, MarketConfig, SetConfig} from "script/interfaces/structs/Configs.sol";
import {MarketState, SetState} from "script/interfaces/structs/StateEnums.sol";

contract ScriptUtils is Script {
  using stdJson for string;

  string INPUT_FOLDER = "/script/input/";

  // Returns the json string for the specified filename from `INPUT_FOLDER`.
  function readInput(string memory _fileName) internal view returns (string memory) {
    string memory _root = vm.projectRoot();
    string memory _chainInputFolder = string.concat(INPUT_FOLDER, vm.toString(block.chainid), "/");
    string memory _inputFile = string.concat(_fileName, ".json");
    string memory _inputPath = string.concat(_root, _chainInputFolder, _inputFile);
    return vm.readFile(_inputPath);
  }

  function safeCastTo16(uint256 x) internal pure returns (uint16 y) {
    require(x < 1 << 16, "safeCastTo16 failed");
    y = uint16(x);
  }

  function _getSetConfig(ISet set_) internal view returns (SetConfig memory) {
    (uint32 leverageFactor_, uint16 depositFee_, bool rebalanceWeightsOnTrigger_) = set_.setConfig();
    return SetConfig(leverageFactor_, depositFee_, rebalanceWeightsOnTrigger_);
  }

  function _getMarket(ISet set_, uint16 marketId_) internal view returns (ISet.MarketStorage memory) {
    (
      address ptoken_,
      address trigger_,
      ISet.MarketConfigStorage memory config_,
      MarketState state_,
      uint256 activeProtection_,
      uint256 lastDecayRate_,
      uint256 lastDripRate_,
      uint128 purchasesFeePool_,
      uint128 salesFeePool_,
      uint64 lastDecayTime_
    ) = set_.markets(marketId_);
    return ISet.MarketStorage(
      ptoken_,
      trigger_,
      config_,
      state_,
      activeProtection_,
      lastDecayRate_,
      lastDripRate_,
      purchasesFeePool_,
      salesFeePool_,
      lastDecayTime_
    );
  }

  function _getMarketFromTrigger(ISet set_, address trigger_) internal view returns (ISet.MarketStorage memory) {
    (, uint16 marketId_) = set_.triggerLookups(trigger_);
    return _getMarket(set_, marketId_);
  }

  function _getLastConfigUpdate(ISet set_) internal view returns (ConfigUpdateMetadata memory) {
    (bytes32 queuedConfigUpdateHash_, uint64 configUpdateTime_, uint64 configUpdateDeadline_) = set_.lastConfigUpdate();
    return ConfigUpdateMetadata(queuedConfigUpdateHash_, configUpdateTime_, configUpdateDeadline_);
  }

  // Implementation reference https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d.
  function _sortMarketConfigArray(MarketConfig[] memory marketConfigs_) internal pure returns (MarketConfig[] memory) {
    // Copy the marketConfigs_ array.
    MarketConfig[] memory sortedMarketConfigs_ = new MarketConfig[](marketConfigs_.length);
    for (uint256 i = 0; i < sortedMarketConfigs_.length; i++) {
      sortedMarketConfigs_[i] = marketConfigs_[i];
    }

    // Quicksort the copied array.
    if (sortedMarketConfigs_.length > 1) _quickPart(sortedMarketConfigs_, 0, sortedMarketConfigs_.length - 1);
    return sortedMarketConfigs_;
  }

  function _quickPart(MarketConfig[] memory marketConfigs_, uint256 low, uint256 high) internal pure {
    if (low < high) {
      address pivotVal = address(marketConfigs_[(low + high) / 2].trigger);

      uint256 low1 = low;
      uint256 high1 = high;
      for (;;) {
        while (address(marketConfigs_[low1].trigger) < pivotVal) low1++;
        while (address(marketConfigs_[high1].trigger) > pivotVal) high1--;
        if (low1 >= high1) break;
        (marketConfigs_[low1], marketConfigs_[high1]) = (marketConfigs_[high1], marketConfigs_[low1]);
        low1++;
        high1--;
      }
      if (low < high1) _quickPart(marketConfigs_, low, high1);
      high1++;
      if (high1 < high) _quickPart(marketConfigs_, high1, high);
    }
  }
}
