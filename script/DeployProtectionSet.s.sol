pragma solidity 0.8.15;

import "forge-std/Script.sol";

contract DeployProtectionSet is Script {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  // All variables defined in this section should be considered/updated before execution of this script.

  // -------- Cozy Contracts --------

  // Address of the Cozy protocol Manager.
  IManager manager = IManager(address(0xBEEF));

  // Address of the Cozy Lens.
  ICozyLens lens = ICozyLens(address(0xBEEF));

  // -------- Market Info --------

  // The trigger addresses for each market in the set.
  address[] triggers = [address(0xBEEF), address(0xBEEF)];

  // The cost models for each market in the set. The indices of this array map 1:1 with the triggers array.
  address[] memory costModels = [address(0xBEEF), address(0xBEEF)];

  // The weights for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Weights are denoted in zoc (1e4). For example, 4000 is equivalent to 40%.
  // NOTE: The sum of weights must equal to 1 zoc (1e4).
  uint16[] weights = [4000, 6000];

  //  The purchase fees for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Purchase fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
  uint16[] purchaseFees = [50, 50];

  // -------- Set Config --------

  // The leverage factor of the set.
  // NOTE: Leverage factors are denoted in zoc (1e4). For example, 1e4 is equivalent to 1x leverage.
  // NOTE: A valid leverage factor must meet the following requirements:
  //   1. It must be greater than or equal to 1 zoc, or 1e4, which is equal to 1x leverage.
  //   2. The maximum theoretical leverage factor for a set is equal to `zoc * number of markets`, e.g. 30000 (3x) for three
  //      markets. Using the max leverage factor requires that all markets in the set have equal weights.
  //   3. The maximum leverage factor for a set is bounded by the max weight of all sets in a market, and is equal to
  //      `1 / max(weights)`. This means we need `leverageFactor / zoc > zoc / max(weights)`.
  uint256 leverageFactor = 10000;

  // The fee charged by the Set owner on deposits.
  uint256 depositFee = 100;

  // Address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
  address decayModel = address(0xBEEF);

  // Address of the set's drip model. The drip model governs the interest rate earned by depositors.
  address dripModel = address(0xBEEF);

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run() public {
    // For each market in the set (including any additions), a MarketInfo object must be added to _marketInfos.
    IConfig.MarketInfo[] memory _marketInfos = new IConfig.MarketInfo[](triggers.length);
    console2.log("Market configs:");
    for (uint256 i = 0; i < triggers.length; i++) {
      IConfig.MarketInfo memory _currentMarketInfo = lens.getMarketInfo(set, triggers[i]);

      _marketInfos[i] = IConfig.MarketInfo({
        trigger: triggers[i],
        costModel: costModels[i] == address(0) ? _currentMarketInfo.costModel : costModels[i],
        weight: weights[i] == type(uint256).max ? _currentMarketInfo.weight : weights[i],
        purchaseFee: purchaseFees[i] == type(uint256).max ? _currentMarketInfo.purchaseFee : purchaseFees[i]
      });

      console2.log("    trigger", _marketInfos[i].trigger);
      console2.log("    weight", _marketInfos[i].weight);
      console2.log("    purchase fee", _marketInfos[i].purchaseFee);
      console2.log("    --------");
    }

    IConfig.SetConfig memory _setConfig = IConfig.SetConfig(leverageFactor, depositFee, decayModel, dripModel);

    address _asset = address(0xFA1AFE1);

    vm.broadcast();
    ISet _set = manager.createSet(owner, pauser, _asset, _setConfig, _marketInfos, salt);
    console2.log("Set deployed", address(_set))
  }

  // -------------------------
  // -------- Helpers --------
  // -------------------------

  // Implementation reference https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d.
  function _sortMarketInfoArray(IConfig.MarketInfo[] memory _marketInfos) internal pure returns(IConfig.MarketInfo[] memory) {
    // Copy the _marketInfos array.
    IConfig.MarketInfo[] memory _sortedMarketInfos = new IConfig.MarketInfo[](_marketInfos.length);
    for (uint256 i = 0; i < _sortedMarketInfos.length; i++) {
      _sortedMarketInfos[i] = _marketInfos[i];
    }

    // Quicksort the copied array.
    if (_sortedMarketInfos.length > 1) {
      _quickPart(_sortedMarketInfos, 0, _sortedMarketInfos.length - 1);
    }
    return _sortedMarketInfos;
  }

  function _quickPart(IConfig.MarketInfo[] memory _marketInfos, uint256 low, uint256 high) internal pure {
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
      if (low < high1) _quickPart(_marketInfos, low, high1);
      high1++;
      if (high1 < high) _quickPart(_marketInfos, high1, high);
    }
  }
}