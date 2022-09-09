pragma solidity 0.8.15;

import "forge-std/Script.sol";

import "script/ScriptUtils.sol";
import "src/interfaces/IManager.sol";
import "src/interfaces/ISet.sol";

/**
  * @notice *Purpose: Local deploy, testing, and production.*
  *
  * This script deploys a protection set using the configured market info and set configuration.
  * Before executing, the configuration section in the script should be updated.
  *
  * To run this script:
  *
  * ```sh
  * # Start anvil, forking from the current state of the desired chain.
  * anvil --fork-url $OPTIMISM_RPC_URL
  *
  * # In a separate terminal, perform a dry run the script.
  * forge script script/DeployProtectionSet.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   -vvvv
  *
  * # Or, to broadcast a transaction.
  * forge script script/DeployProtectionSet.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   --private-key $OWNER_PRIVATE_KEY \
  *   --broadcast \
  *   -vvvv
  * ```
 */
contract DeployProtectionSet is Script, ScriptUtils {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  // All variables defined in this section should be considered/updated before execution of this script.

  // -------- Cozy Contracts --------

  // Address of the Cozy protocol Manager.
  IManager manager = IManager(address(0xBEEF));

  // -------- Market Info --------

  // The trigger addresses for each market in the set.
  address[] triggers = [address(0xBEEF), address(0xBEEF)];

  // The cost models for each market in the set. The indices of this array map 1:1 with the triggers array.
  ICostModel[] costModels = [ICostModel(address(0xBEEF)), ICostModel(address(0xBEEF))];

  // The weights for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Weights are denoted in zoc (1e4). For example, 4000 is equivalent to 40%.
  // NOTE: The sum of weights must equal to 1 zoc (1e4).
  uint16[] weights = [4000, 6000];

  // The purchase fees for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Purchase fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
  uint16[] purchaseFees = [50, 50];

  // -------- Set Configuration --------

  // The leverage factor of the set.
  // NOTE: Leverage factors are denoted in zoc (1e4). For example, 1e4 is equivalent to 1x leverage.
  // NOTE: A valid leverage factor must meet the following requirements:
  //   1. It must be greater than or equal to 1 zoc, or 1e4, which is equal to 1x leverage.
  //   2. The maximum theoretical leverage factor for a set is equal to `zoc * number of markets`, e.g. 30000 (3x) for three
  //      markets. Using the max leverage factor requires that all markets in the set have equal weights.
  //   3. The maximum leverage factor for a set is bounded by the max weight of all sets in a market, and is equal to
  //      `1 / max(weights)`. This means we need `leverageFactor / zoc > zoc / max(weights)`.
  uint256 constant leverageFactor = 10000;

  // The fee charged by the Set owner on deposits.
  uint256 constant depositFee = 100;

  // Address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
  IDecayModel constant decayModel = IDecayModel(address(0xBEEF));

  // Address of the set's drip model. The drip model governs the interest rate earned by depositors.
  IDripModel constant dripModel = IDripModel(address(0xBEEF));

  // Address of the underlying asset of the set.
  address constant asset = address(0xBEEF);

  // Arbitrary salt used for Set contract deploy.
  bytes32 constant salt = bytes32(hex"01");

  // -------- Set Authorized Roles --------

  // The owner of the set.
  address owner = address(0xBEEF);

  // The pauser of the set.
  address pauser = address(0xBEEF);

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run() public {
    // For each market in the set, a MarketInfo object must be added to _marketInfos.
    IConfig.MarketInfo[] memory _marketInfos = new IConfig.MarketInfo[](triggers.length);
    console2.log("Market infos:");
    for (uint256 i = 0; i < triggers.length; i++) {
      _marketInfos[i] = IConfig.MarketInfo({
        trigger: triggers[i],
        costModel: costModels[i],
        weight: weights[i],
        purchaseFee: purchaseFees[i]
      });

      console2.log("    trigger", address(_marketInfos[i].trigger));
      console2.log("    cost model", address(_marketInfos[i].costModel));
      console2.log("    weight", _marketInfos[i].weight);
      console2.log("    purchase fee", _marketInfos[i].purchaseFee);
      console2.log("    --------");
    }
    console2.log("====================");

    // Sort the market config array.
    IConfig.MarketInfo[] memory _sortedMarketInfos = _sortMarketInfoArray(_marketInfos);

    IConfig.SetConfig memory _setConfig = IConfig.SetConfig(leverageFactor, depositFee, decayModel, dripModel);
    console2.log("Set config:");
    console2.log("    leverage factor", _setConfig.leverageFactor);
    console2.log("    deposit fee", _setConfig.depositFee);
    console2.log("    decay model", address(_setConfig.decayModel));
    console2.log("    drip model", address(_setConfig.dripModel));
    console2.log("    asset", asset);
    console2.log("====================");

    console2.log("Set authorized roles:");
    console2.log("    owner", owner);
    console2.log("    pauser", pauser);
    console2.log("====================");

    vm.broadcast();
    ISet _set = manager.createSet(owner, pauser, asset, _setConfig, _sortedMarketInfos, salt);
    console2.log("Set deployed", address(_set));
  }
}