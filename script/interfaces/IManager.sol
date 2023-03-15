// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {MarketConfig, SetConfig} from "script/interfaces/structs/Configs.sol";

interface IManager {
  function createSet(
    address owner_,
    address pauser_,
    address asset_,
    SetConfig memory setConfig_,
    MarketConfig[] memory marketConfigs_,
    bytes32 salt_
  ) external returns (address set_);

  function owner() external view returns (address);
}
