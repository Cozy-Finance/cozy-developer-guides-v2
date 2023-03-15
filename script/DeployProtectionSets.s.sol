pragma solidity 0.8.18;

import {ScriptUtils} from "script/ScriptUtils.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2} from "forge-std/console2.sol";
import {IManager} from "script/interfaces/IManager.sol";
import {MarketConfig, SetConfig} from "script/interfaces/structs/Configs.sol";

/**
 * @dev This script deploys protection sets using the configured market info and set configuration.
 * Before executing, the input json file `script/input/<chain-id>/<filename>.json` should be reviewed.
 *
 * To run this script:
 *
 * ```sh
 * # Start anvil, forking from the current state of the desired chain.
 * anvil --fork-url $OPTIMISM_RPC_URL
 *
 * # In a separate terminal, perform a dry run the script.
 * forge script script/DeployProtectionSets.s.sol \
 *   --sig "run(string)" "deploy-protection-sets-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   -vvvv
 *
 * # Or, to broadcast transactions.
 * forge script script/DeployProtectionSets.s.sol \
 *   --sig "run(string)" "deploy-protection-sets-<test or production>"
 *   --rpc-url "http://127.0.0.1:8545" \
 *   --private-key $OWNER_PRIVATE_KEY \
 *   --broadcast \
 *   -vvvv
 * ```
 */
contract DeployProtectionSets is ScriptUtils {
  using stdJson for string;

  // -----------------------------------
  // -------- Configured Inputs --------
  // -----------------------------------

  // Note: The attributes in this struct must be in alphabetical order due to `parseJson` limitations.
  struct SetMetadata {
    // Address of the underlying IERC20 asset of the set.
    address asset;
    // The fee charged by the Set owner on deposits.
    uint16 depositFee;
    // The leverage factor of the set.
    // NOTE: Leverage factors are denoted in zoc (1e4). For example, 1e4 is equivalent to 1x leverage.
    // NOTE: A valid leverage factor must meet the following requirements:
    //   1. It must be greater than or equal to 1 zoc, or 1e4, which is equal to 1x leverage.
    //   2. The maximum theoretical leverage factor for a set is equal to `zoc * number of markets`, e.g. 30000 (3x) for
    // three
    //      markets. Using the max leverage factor requires that all markets in the set have equal weights.
    //   3. The maximum leverage factor for a set is bounded by the max weight of all sets in a market, and is equal to
    //      `1 / max(weights)`. This means we need `leverageFactor / zoc > zoc / max(weights)`.
    uint32 leverageFactor;
    // List of metadata for each market in the set.
    MarketMetadata[] markets;
    // The owner of the set.
    address owner;
    // The pauser of the set.
    address pauser;
    // Arbitrary salt used for Set contract deploy.
    bytes32 salt;
  }

  // Note: The attributes in this struct must be in alphabetical order due to `parseJson` limitations.
  struct MarketMetadata {
    // The cost model for the market.
    address costModel;
    // Address of the set's drip/decay model. The model governs how fast outstanding protection loses it's value, and
    // the interest rate earned by depositers.
    address dripDecayModel;
    // The purchase fee for the market.
    // NOTE: Purchase fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
    uint16 purchaseFee;
    // The sale fee for the market.
    // NOTE: Sale fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
    uint16 saleFee;
    // The trigger for the market.
    address trigger;
    // The weights for each market.
    // NOTE: Weights are denoted in zoc (1e4). For example, 4000 is equivalent to 40%.
    // NOTE: The sum of weights for each market in a set must equal to 1 zoc (1e4).
    uint16 weight;
  }

  // Address of the Cozy protocol Manager.
  IManager manager;

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run(string memory _fileName) public {
    string memory _json = readInput(_fileName);

    manager = IManager(_json.readAddress(".manager"));
    // Loosely validate manager interface by ensuring `owner()` doesn't revert.
    manager.owner();

    SetMetadata[] memory _setMetadata = abi.decode(_json.parseRaw(".sets"), (SetMetadata[]));

    for (uint256 j = 0; j < _setMetadata.length; j++) {
      SetMetadata memory _set = _setMetadata[j];

      // For each market in the set, a MarketConfig object must be added to _marketConfigs.
      MarketConfig[] memory _marketConfigs = new MarketConfig[](_set.markets.length);
      console2.log("Market configs:");
      for (uint256 i = 0; i < _set.markets.length; i++) {
        _marketConfigs[i] = MarketConfig({
          trigger: _set.markets[i].trigger,
          costModel: _set.markets[i].costModel,
          dripDecayModel: _set.markets[i].dripDecayModel,
          weight: _set.markets[i].weight,
          purchaseFee: _set.markets[i].purchaseFee,
          saleFee: _set.markets[i].saleFee
        });

        console2.log("    trigger", address(_marketConfigs[i].trigger));
        console2.log("    cost model", address(_marketConfigs[i].costModel));
        console2.log("    drip decay model", address(_marketConfigs[i].dripDecayModel));
        console2.log("    weight", _marketConfigs[i].weight);
        console2.log("    purchase fee", _marketConfigs[i].purchaseFee);
        console2.log("    sale fee", _marketConfigs[i].saleFee);
        console2.log("    --------");
      }
      console2.log("====================");

      // Sort the market config array.
      MarketConfig[] memory _sortedMarketConfigs = _sortMarketConfigArray(_marketConfigs);

      SetConfig memory _setConfig = SetConfig(_set.leverageFactor, _set.depositFee);
      console2.log("Set config:");
      console2.log("    leverage factor", _set.leverageFactor);
      console2.log("    deposit fee", _set.depositFee);
      console2.log("====================");

      console2.log("Set authorized roles:");
      console2.log("    owner", _set.owner);
      console2.log("    pauser", _set.pauser);
      console2.log("====================");

      address _asset = _set.asset;
      vm.broadcast();
      address _setDeployed =
        manager.createSet(_set.owner, _set.pauser, _asset, _setConfig, _sortedMarketConfigs, _set.salt);
      console2.log("Set deployed", _setDeployed);
      console2.log("    asset", _asset);
      console2.log("====================");
    }
  }
}
