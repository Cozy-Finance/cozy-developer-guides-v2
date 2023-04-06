// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketState, SetState} from "script/interfaces/structs/StateEnums.sol";
import {MarketConfig, SetConfig} from "script/interfaces/structs/Configs.sol";

interface ISet {
  struct MarketStorage {
    address ptoken;
    address trigger;
    MarketConfigStorage config;
    MarketState state;
    uint256 activeProtection;
    uint256 lastDecayRate;
    uint256 lastDripRate;
    uint128 purchasesFeePool;
    uint128 salesFeePool;
    uint64 lastDecayTime;
  }

  struct MarketConfigStorage {
    address costModel;
    address dripDecayModel;
    uint16 weight;
    uint16 purchaseFee;
    uint16 saleFee;
  }

  function finalizeUpdateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;
  function lastConfigUpdate()
    external
    view
    returns (bytes32 queuedConfigUpdateHash, uint64 configUpdateTime, uint64 configUpdateDeadline);
  function markets(uint256)
    external
    view
    returns (
      address ptoken,
      address trigger,
      MarketConfigStorage memory config,
      MarketState state,
      uint256 activeProtection,
      uint256 lastDecayRate,
      uint256 lastDripRate,
      uint128 purchasesFeePool,
      uint128 salesFeePool,
      uint64 lastDecayTime
    );
  function setConfig() external view returns (uint32 leverageFactor, uint16 depositFee, bool rebalanceWeightsOnTrigger);
  function setState() external view returns (SetState);
  function triggerLookups(address) external view returns (bool marketExists, uint16 marketId);
  function updateConfigs(SetConfig memory setConfig_, MarketConfig[] memory marketConfigs_) external;
}
