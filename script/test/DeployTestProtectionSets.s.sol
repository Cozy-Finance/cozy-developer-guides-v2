pragma solidity 0.8.15;

import "forge-std/Script.sol";

import "script/ScriptUtils.sol";

/**
  * @notice *Purpose: Local deploy, testing, and production.*
  *
  * This script deploys two protection sets for testing using the configured market info and set configuration on Optimism.
  * The two sets use the same configuration except one of the sets uses USDC, and the other uses WETH.
  * Before executing, the configuration section of the script should be reviewed.
  *
  * To run this script:
  *
  * ```sh
  * # Start anvil, forking from the current state of the desired chain.
  * anvil --fork-url $OPTIMISM_RPC_URL
  *
  * # In a separate terminal, perform a dry run the script.
  * forge script script/DeployTestProtectionSets.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   -vvvv
  *
  * # Or, to broadcast a transaction.
  * forge script script/DeployTestProtectionSets.s.sol \
  *   --rpc-url "http://127.0.0.1:8545" \
  *   --private-key $OWNER_PRIVATE_KEY \
  *   --broadcast \
  *   -vvvv
  * ```
 */
contract DeployTestProtectionSets is Script, ScriptUtils {
  // -------------------------------
  // -------- Configuration --------
  // -------------------------------

  // All variables defined in this section should be considered/updated before execution of this script.

  // -------- Cozy Contracts --------

  // Address of the Cozy protocol Manager.
  IManager manager = IManager(0x91d82e1172A70cF8cac704ae5E3Dd4327FdadD58);

  // -------- Market Info --------

  // The trigger addresses for each market in the set.
  address[] triggers = [
    0x24Cb8DE4f381b06D66C7607bF1d080D89442fda2,
    0x737330fC2ac9b8E62ccD7A182d785914C4e88FB7,
    0x0C22d6e2C242a37bBc4dFcbF50704DcD3FD5162e,
    0x37136e49dBF24D11F6d42cAB89784B9092f934C9,
    0x27F495Ce3a1Af8B647eC58834ff4354f5dc357d0,
    0x1b2987da4e34C0e34dfECd8D6Ef7f8f0aAAe5f49
  ];

  // The cost models for each market in the set. The indices of this array map 1:1 with the triggers array.
  ICostModel[] costModels = [
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991),
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991),
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991),
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991),
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991),
    ICostModel(0x7e5a2bDC10F05D6cF15563570Eae3B8d346B9991)
  ];

  // The weights for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Weights are denoted in zoc (1e4). For example, 4000 is equivalent to 40%.
  // NOTE: The sum of weights must equal to 1 zoc (1e4).
  uint16[] weights = [1666, 1666, 1667, 1667, 1667, 1667];

  // The purchase fees for each market. The indices of this array map 1:1 with the triggers array.
  // NOTE: Purchase fees are denoted in zoc (1e4). For example, 50 is equivalent to 0.5%.
  uint16[] purchaseFees = [
    250,
    250,
    250,
    250,
    250,
    250
  ];

  // -------- Set Configuration --------

  // The leverage factor of the set.
  // NOTE: Leverage factors are denoted in zoc (1e4). For example, 1e4 is equivalent to 1x leverage.
  // NOTE: A valid leverage factor must meet the following requirements:
  //   1. It must be greater than or equal to 1 zoc, or 1e4, which is equal to 1x leverage.
  //   2. The maximum theoretical leverage factor for a set is equal to `zoc * number of markets`, e.g. 30000 (3x) for three
  //      markets. Using the max leverage factor requires that all markets in the set have equal weights.
  //   3. The maximum leverage factor for a set is bounded by the max weight of all sets in a market, and is equal to
  //      `1 / max(weights)`. This means we need `leverageFactor / zoc > zoc / max(weights)`.
  uint256 constant leverageFactor = 30000;

  // The fee charged by the Set owner on deposits.
  uint256 constant depositFee = 0;

  // Address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
  IDecayModel constant decayModel = IDecayModel(0x09f20eA12fe5a1211A0485aa59C067E9fcC4c04A);

  // Address of the set's drip model. The drip model governs the interest rate earned by depositors.
  IDripModel constant dripModel = IDripModel(0xEf778611eAf2e624432F49bcF7AC433584f642a2);

  // Address of the underlying asset of the set.
  address[] assets = [
    0x7F5c764cBc14f9669B88837ca1490cCa17c31607, // Optimism USDC.
    0x4200000000000000000000000000000000000006 // Optimism WETH.
  ];

  // Arbitrary salt used for Set contract deploy.
  bytes32[] salts = [bytes32(hex"01"), bytes32(hex"02")];

  // -------- Set Authorized Roles --------

  // The owner of the set.
  address owner = 0x682bd405073dD248527E40184898eD45BB827527;

  // The pauser of the set.
  address pauser = 0x682bd405073dD248527E40184898eD45BB827527;

  // ---------------------------
  // -------- Execution --------
  // ---------------------------

  function run() public {
    // For each market in the set, a MarketInfo object must be added to _marketInfos.
    MarketInfo[] memory _marketInfos = new MarketInfo[](triggers.length);
    console2.log("Market infos:");
    for (uint256 i = 0; i < triggers.length; i++) {
      _marketInfos[i] = MarketInfo({
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
    MarketInfo[] memory _sortedMarketInfos = _sortMarketInfoArray(_marketInfos);

    SetConfig memory _setConfig = SetConfig(leverageFactor, depositFee, decayModel, dripModel);
    console2.log("Set config:");
    console2.log("    leverage factor", _setConfig.leverageFactor);
    console2.log("    deposit fee", _setConfig.depositFee);
    console2.log("    decay model", address(_setConfig.decayModel));
    console2.log("    drip model", address(_setConfig.dripModel));
    console2.log("====================");

    console2.log("Set authorized roles:");
    console2.log("    owner", owner);
    console2.log("    pauser", pauser);
    console2.log("====================");

    // Deploy each set.
    for (uint i = 0; i < assets.length; i++) {
      address _asset = assets[i];
      vm.broadcast();
      ISet _set = manager.createSet(owner, pauser, _asset, _setConfig, _sortedMarketInfos, salts[i]);
      console2.log("Set deployed", address(_set));
      console2.log("    asset", _asset);
      console2.log("====================");
    }
  }
}