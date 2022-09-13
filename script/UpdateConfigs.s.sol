pragma solidity 0.8.15;

import "forge-std/Script.sol";

import "script/ScriptUtils.sol";
import "cozy-v2-interfaces/interfaces/ICozyLens.sol";

/**
  * @notice *Purpose: Update set and market configurations.*
  *
  * This script requires the protocol and a set to be deployed on the desired chain.
  * The script includes a "Configuration" section at the top, which must be updated to the desired set/market config updates.
  *
  * This script behaves as follows:
  * - It will queue the configured set and market config updates if they have not already been queued, or if they have and the deadline to apply them has passed.
  * - If the config updates have been queued and the current timestamp is within the allowed timeframe to apply queued config updates, this script will apply the queued config updates.
  *
  * Running the script with config updates that have already been queued (whether or not this script was used to do so) will apply
  * the queued config updates if the current timestamp is within the allowed window to apply config changes and if the set is active.
  *
  * To run this script:
  *
  * ```sh
  * # Start anvil, forking from the current state of the desired chain.
  * anvil --fork-url $OPTIMISM_RPC_URL
  *
  * # In a separate terminal, perform a dry run the script.
  * # The private key of either the set owner or protocol owner must be included in order to queue config updates.
  * forge script script/UpdateConfigs.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   --private-key $OWNER_PRIVATE_KEY \
  *   -vvvv
  *
  * # To broadcast a transaction, just add the `--broadcast` flag.
  * forge script script/UpdateConfigs.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   --private-key $OWNER_PRIVATE_KEY \
  *   --broadcast \
  *   -vvvv
  * ```
*/
contract UpdateConfigs is Script, ScriptUtils {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  // -------- Constants --------

  ICozyLens lens = ICozyLens(address(0xBEEF));
  IManager manager = IManager(address(0xBEEF));
  ISet set = ISet(address(0xBEEF));

  // -------- SetConfig --------

  // NOTE: If you'd like to use the set's current config (no-op), specify type(uint256).max) for uint256s and address(0) for addresses.
  uint256 constant leverageFactor = type(uint256).max;
  uint256 constant depositFee = type(uint256).max;
  address constant decayModel = address(0);
  address constant dripModel = address(0);

  // -------- MarketInfo --------

  // The triggers for each market in the set, including any new markets.
  // NOTE: This array must include triggers for all markets in the set.
  address[] triggers = [address(0xBEEF), address(0xBEEF)];

  // The cost models for each market in the set, including any new markets. The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current cost model (no-op), specify address(0) for that index.
  address[] costModels = [address(0), address(0)];

  // The weights for each market, including any new markets. The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current weight (no-op), specify type(uint16).max) for that index.
  uint16[] weights = [type(uint16).max, type(uint16).max];

  // The purchase fees for each market, including any new markets. The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current purchase fee (no-op), specify type(uint16).max) for that index.
  uint16[] purchaseFees = [type(uint16).max, type(uint16).max];

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run() public {
    SetConfig memory _currentSetConfig = lens.getSetConfig(set);

    SetConfig memory _setConfig = SetConfig(
      leverageFactor == type(uint256).max ? _currentSetConfig.leverageFactor : leverageFactor,
      depositFee == type(uint256).max ? _currentSetConfig.depositFee : depositFee,
      decayModel == address(0) ? _currentSetConfig.decayModel : IDecayModel(decayModel),
      dripModel == address(0) ? _currentSetConfig.dripModel : IDripModel(dripModel)
    );

    console2.log("Set config:");
    console2.log("    leverageFactor", _setConfig.leverageFactor);
    console2.log("    depositFee", _setConfig.depositFee);
    console2.log("    decayModel", address(_setConfig.decayModel));
    console2.log("    dripModel", address(_setConfig.dripModel));
    console2.log("====================");

    // For each market in the set (including any additions), a MarketInfo object must be added to _marketInfos.
    MarketInfo[] memory _marketInfos = new MarketInfo[](triggers.length);
    console2.log("Market configs:");
    for (uint256 i = 0; i < triggers.length; i++) {
      MarketInfo memory _currentMarketInfo = lens.getMarketInfo(set, triggers[i]);

      _marketInfos[i] = MarketInfo({
        trigger: triggers[i],
        costModel: costModels[i] == address(0) ? _currentMarketInfo.costModel : ICostModel(costModels[i]),
        weight: weights[i] == type(uint16).max ? _currentMarketInfo.weight : weights[i],
        purchaseFee: purchaseFees[i] == type(uint16).max ? _currentMarketInfo.purchaseFee : purchaseFees[i]
      });

      console2.log("    trigger", _marketInfos[i].trigger);
      console2.log("    weight", _marketInfos[i].weight);
      console2.log("    purchase fee", _marketInfos[i].purchaseFee);
      console2.log("    --------");
    }
    console2.log("====================");

    // Sort the market config array.
    MarketInfo[] memory _sortedMarketInfos = _sortMarketInfoArray(_marketInfos);

    // If the config updates are not yet queued or if they have already been queued but the deadline to apply them has passed, queue them.
    bytes32 _configUpdateHash = keccak256(abi.encode(_setConfig, _sortedMarketInfos));
    if (_configUpdateHash != manager.queuedConfigUpdateHash(set) || block.timestamp > lens.getConfigUpdateDeadline(set)) {
      console2.log("Queuing config updates...");
      vm.broadcast();
      manager.updateConfigs(set, _setConfig, _sortedMarketInfos);
      console2.log("Config updates queued.");
      console2.log("    getConfigUpdateTime", lens.getConfigUpdateTime(set));
      console2.log("    getConfigUpdateDeadline", lens.getConfigUpdateDeadline(set));
    }

    // Apply the queued config updates if time requirements are met and the set is active.
    if (
      block.timestamp >= lens.getConfigUpdateTime(set) &&
      block.timestamp <= lens.getConfigUpdateDeadline(set) &&
      set.state(address(set)) == ICState.CState.ACTIVE
    ) {
      console2.log("Finalizing config updates...");
      vm.broadcast();
      manager.finalizeUpdateConfigs(set, _setConfig, _sortedMarketInfos);
      console2.log("Config update applied.");
    } else {
      console2.log("ERROR: The queued config updates cannot be applied because the current time is not within the allowed range [configUpdateTime, configUpdateDeadline], or the set is not active");
      revert();
    }
  }
}