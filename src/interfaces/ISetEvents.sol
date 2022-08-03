// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface ISetEvents {
  event Cancellation(address caller, address indexed receiver, address indexed owner, uint256 protection, uint256 ptokens, address indexed trigger, uint256 refund);
  event Claim(address caller, address indexed receiver, address indexed owner, uint256 protection, uint256 ptokens, address indexed trigger);
  event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
  event Purchase(address indexed caller, address indexed owner, uint256 protection, uint256 ptokens, address indexed trigger, uint256 cost);
  event Withdraw(address caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares, uint256 indexed withdrawalId);
  event WithdrawalPending(address caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares, uint256 indexed withdrawalId);
}