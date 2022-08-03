// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISetTypes {
  struct PendingWithdrawal { uint128 shares; uint128 assets; address owner; uint64 queueTime; address receiver; uint64 delay; }
}