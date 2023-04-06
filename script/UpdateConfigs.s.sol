// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ScriptUtils} from "script/ScriptUtils.sol";
import {console2} from "forge-std/console2.sol";
import {ISet} from "script/interfaces/ISet.sol";
import {ConfigUpdateMetadata, MarketConfig, SetConfig} from "script/interfaces/structs/Configs.sol";
import {MarketState, SetState} from "script/interfaces/structs/StateEnums.sol";

/**
 * @dev This script is used to update the configuration for a set.
 * Before executing, the configuration section of this file should be reviewed.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run the script.
 * forge script script/UpdateConfigs.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast transactions.
 * forge script script/UpdateConfigs.s.sol \
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract UpdateConfigs is ScriptUtils {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  // -------- Constants --------

  ISet set = ISet(address(0xBEEF));

  // -------- SetConfig --------

  // NOTE: If you'd like to use the set's current config (no-op), specify type(uint256).max for uint256s and
  // address(0) for addresses.
  uint256 constant leverageFactor = type(uint256).max;
  uint256 constant depositFee = type(uint256).max;

  // If true, the weight of a market when triggered is automatically distributed pro rata among non-triggered markets.
  // If false, the set admin must manually rebalance weights through a configuration update.
  bool rebalanceWeightsOnTrigger = false;

  // -------- MarketConfig --------

  // The triggers for each market in the set, including any new markets.
  // NOTE: This array must include triggers for all markets in the set.
  address[] triggers = [address(0xBEEF), address(0xBEEF)];

  // The cost models for each market in the set, including any new markets.
  // The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current cost model (no-op),
  // specify address(0) for that index.
  address[] costModels = [address(0), address(0)];

  // The drip decay models for each market in the set, including any new markets.
  // The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current drip decay model (no-op),
  // specify address(0) for that index.
  address[] dripDecayModels = [address(0), address(0)];

  // The weights for each market, including any new markets. The indices of this array map 1:1 with the triggers
  // array.
  // NOTE: For an existing market, if you'd like to use its current weight (no-op),
  // specify type(uint256).max) for that index.
  uint256[] weights = [type(uint256).max, type(uint256).max];

  // The purchase fees for each market, including any new markets.
  // The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current purchase fee (no-op),
  // specify type(uint256).max) for that index.
  uint256[] purchaseFees = [type(uint256).max, type(uint256).max];

  // The sale penalties for each market, including any new markets.
  // The indices of this array map 1:1 with the triggers array.
  // NOTE: For an existing market, if you'd like to use its current sale penalty (no-op),
  // specify type(uint256).max) for that index.
  uint256[] saleFees = [type(uint256).max, type(uint256).max];

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run() public {
    SetConfig memory currentSetConfig_ = _getSetConfig(set);

    SetConfig memory setConfig_ = SetConfig(
      leverageFactor == type(uint256).max ? currentSetConfig_.leverageFactor : uint32(leverageFactor),
      depositFee == type(uint256).max ? currentSetConfig_.depositFee : uint16(depositFee),
      rebalanceWeightsOnTrigger
    );

    console2.log("Set config:");
    console2.log("    leverageFactor", setConfig_.leverageFactor);
    console2.log("    depositFee", setConfig_.depositFee);
    console2.log("    rebalanceWeightsOnTrigger", setConfig_.rebalanceWeightsOnTrigger);
    console2.log("====================");

    // For each market in the set (including any additions), a MarketInfo object must be added to _marketInfos.
    MarketConfig[] memory marketConfigs_ = new MarketConfig[](triggers.length);
    console2.log("Market configs:");
    for (uint256 i = 0; i < triggers.length; i++) {
      ISet.MarketConfigStorage memory currentMarketConfig_ = _getMarketFromTrigger(set, triggers[i]).config;

      marketConfigs_[i] = MarketConfig({
        trigger: triggers[i],
        costModel: costModels[i] == address(0) ? currentMarketConfig_.costModel : costModels[i],
        dripDecayModel: dripDecayModels[i] == address(0) ? currentMarketConfig_.dripDecayModel : dripDecayModels[i],
        weight: safeCastTo16(weights[i] == type(uint256).max ? currentMarketConfig_.weight : weights[i]),
        purchaseFee: safeCastTo16(
          purchaseFees[i] == type(uint256).max ? currentMarketConfig_.purchaseFee : purchaseFees[i]
          ),
        saleFee: safeCastTo16(saleFees[i] == type(uint256).max ? currentMarketConfig_.saleFee : saleFees[i])
      });

      console2.log("    trigger", address(marketConfigs_[i].trigger));
      console2.log("    cost model", address(marketConfigs_[i].costModel));
      console2.log("    drip decay model", address(marketConfigs_[i].dripDecayModel));
      console2.log("    weight", marketConfigs_[i].weight);
      console2.log("    purchase fee", marketConfigs_[i].purchaseFee);
      console2.log("    sale fee", marketConfigs_[i].saleFee);
      console2.log("    --------");
    }
    console2.log("====================");

    // Sort the market config array.
    MarketConfig[] memory sortedMarketConfigs_ = _sortMarketConfigArray(marketConfigs_);

    // If the config updates are not yet queued or if they have already been queued but the deadline to apply them
    // has passed, queue them.
    bytes32 configUpdateHash_ = keccak256(abi.encode(setConfig_, sortedMarketConfigs_));
    ConfigUpdateMetadata memory lastConfigUpdate_ = _getLastConfigUpdate(set);
    if (
      configUpdateHash_ != lastConfigUpdate_.queuedConfigUpdateHash
        || block.timestamp > lastConfigUpdate_.configUpdateDeadline
    ) {
      console2.log("Queuing config updates...");
      vm.broadcast();
      set.updateConfigs(setConfig_, sortedMarketConfigs_);
    }

    // Apply the queued config updates if time requirements are met and the set is active.
    if (
      block.timestamp >= lastConfigUpdate_.configUpdateTime && block.timestamp <= lastConfigUpdate_.configUpdateDeadline
        && set.setState() == SetState.ACTIVE
    ) {
      console2.log("Finalizing config updates...");
      vm.broadcast();
      set.finalizeUpdateConfigs(setConfig_, sortedMarketConfigs_);
    }
  }
}
