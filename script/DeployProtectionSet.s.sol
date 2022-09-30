pragma solidity 0.8.15;

import "script/ScriptUtils.sol";

/**
  * @notice *Purpose: Local deploy, testing, and production.*
  *
  * This script deploys protection sets using the configured market info and set configuration.
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
  *   --sig "run(string)" "deploy-protection-set-<test or production>"
  *   --rpc-url "http://127.0.0.1:8545" \
  *   -vvvv
  *
  * # Or, to broadcast a transaction.
  * forge script script/DeployProtectionSets.s.sol \
  *   --sig "run(string)" "deploy-protection-set-<test or production>"
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
    // Address of the underlying asset of the set.
    address asset;
    // Address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
    IDecayModel decayModel;
    // The fee charged by the Set owner on deposits.
    uint256 depositFee;
    // Address of the set's drip model. The drip model governs the interest rate earned by depositors.
    IDripModel dripModel;
    // The leverage factor of the set.
    // NOTE: Leverage factors are denoted in zoc (1e4). For example, 1e4 is equivalent to 1x leverage.
    // NOTE: A valid leverage factor must meet the following requirements:
    //   1. It must be greater than or equal to 1 zoc, or 1e4, which is equal to 1x leverage.
    //   2. The maximum theoretical leverage factor for a set is equal to `zoc * number of markets`, e.g. 30000 (3x) for three
    //      markets. Using the max leverage factor requires that all markets in the set have equal weights.
    //   3. The maximum leverage factor for a set is bounded by the max weight of all sets in a market, and is equal to
    //      `1 / max(weights)`. This means we need `leverageFactor / zoc > zoc / max(weights)`.
    uint256 leverageFactor;
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
    ICostModel costModel;
    // The purchase fee for the market.
    // NOTE: Purchase fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
    uint16 purchaseFee;
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

    for (uint j = 0; j < _setMetadata.length; j++) {
      SetMetadata memory _set = _setMetadata[j];

      // For each market in the set, a MarketInfo object must be added to _marketInfos.
      MarketInfo[] memory _marketInfos = new MarketInfo[](_set.markets.length);
      console2.log("Market infos:");
      for (uint256 i = 0; i < _set.markets.length; i++) {
        _marketInfos[i] = MarketInfo({
          trigger: _set.markets[i].trigger,
          costModel: _set.markets[i].costModel,
          weight: _set.markets[i].weight,
          purchaseFee: _set.markets[i].purchaseFee
        });

        console2.log("    trigger", address(_marketInfos[i].trigger));
        console2.log("    cost model", address(_marketInfos[i].costModel));
        console2.log("    weight", _marketInfos[i].weight);
        console2.log("    purchase fee", _marketInfos[i].purchaseFee);
        console2.log("    --------");
      }
      console2.log("====================");

      // Sort the market config array.
      MarketInfo[] memory _sortedMarketInfos = _sortMarketInfoArray(_marketInfos);

      SetConfig memory _setConfig = SetConfig(_set.leverageFactor, _set.depositFee, _set.decayModel, _set.dripModel);
      console2.log("Set config:");
      console2.log("    leverage factor", _set.leverageFactor);
      console2.log("    deposit fee", _set.depositFee);
      console2.log("    decay model", address(_set.decayModel));
      console2.log("    drip model", address(_set.dripModel));
      console2.log("====================");

      console2.log("Set authorized roles:");
      console2.log("    owner", _set.owner);
      console2.log("    pauser", _set.pauser);
      console2.log("====================");

      address _asset = _set.asset;
      vm.broadcast();
      ISet _setDeployed = manager.createSet(_set.owner, _set.pauser, _asset, _setConfig, _sortedMarketInfos, _set.salt);
      console2.log("Set deployed", address(_setDeployed));
      console2.log("    asset", _asset);
      console2.log("====================");
    }
  }
}