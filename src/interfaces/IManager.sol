// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IManagerEvents.sol";

interface IManager is IManagerEvents {
  function MAX_FEE() view external returns (uint256);
  function backstop() view external returns (address);
  function cancellationFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function claimCozyFees(ISet[] memory _sets) external;
  function claimSetFees(ISet _set, address _receiver) external;
  function configUpdateDelay() view external returns (uint32);
  function configUpdateGracePeriod() view external returns (uint32);
  function createSet(address _owner, address _pauser, address _asset, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos, bytes32 _salt) external returns (ISet _set);
  function depositFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function fees() view external returns (uint16 depositFeeReserves, uint16 depositFeeBackstop, uint16 purchaseFeeReserves, uint16 purchaseFeeBackstop, uint16 cancellationFeeReserves, uint16 cancellationFeeBackstop);
  function finalizeUpdateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;
  function getDelayTimeAccrued(uint256 _startTime, uint256 _currentInactiveDuration, InactivePeriod[] memory _inactivePeriods) view external returns (uint256);
  function getDepositCap(address _asset) view external returns (uint256);
  function getMarketInactivityData(ISet _set, address _trigger) view external returns (InactivityData memory);
  function getWithdrawDelayTimeAccrued(ISet _set, uint256 _startTime, uint8 _setState) view external returns (uint256 _activeTimeElapsed);
  function inactiveDurationBeforeTimestampLookup(uint256 _timestamp, InactivePeriod[] memory _inactivePeriods) pure external returns (uint256);
  function isAnyMarketFrozen(ISet _set) view external returns (bool);
  function isApprovedForBackstop(ISet _set) view external returns (bool);
  function isLocalSetOwner(ISet _set, address _who) view external returns (bool);
  function isMarket(ISet _set, address _who) view external returns (bool);
  function isOwner(ISet _set, address _who) view external returns (bool);
  function isOwnerOrPauser(ISet _set, address _who) view external returns (bool);
  function isPauser(ISet _set, address _who) view external returns (bool);
  function isValidConfiguration(SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) pure external returns (bool);
  function isValidMarketStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);
  function isValidSetStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);
  function isValidUpdate(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) view external returns (bool);
  function marketInactivityData(address, address) view external returns (uint64 inactiveTransitionTime);
  function minDepositDuration() view external returns (uint32);
  function owner() view external returns (address);
  function pause(ISet _set) external;
  function pauser() view external returns (address);
  function ptokenFactory() view external returns (address);
  function purchaseDelay() view external returns (uint32);
  function purchaseFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function queuedConfigUpdateHash(address) view external returns (bytes32);
  function setFactory() view external returns (address);
  function setInactivityData(address) view external returns (uint64 inactiveTransitionTime);
  function setOwner(address) view external returns (address);
  function setPauser(address) view external returns (address);
  function sets(ISet) view external returns (bool exists, bool approved, uint64 configUpdateTime, uint64 configUpdateDeadline);
  function unpause(ISet _set) external;
  function updateBackstopApprovals(BackstopApproval[] memory _approvals) external;
  function updateConfigParams(uint256 _configUpdateDelay, uint256 _configUpdateGracePeriod) external;
  function updateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;
  function updateDepositCap(address _asset, uint256 _newDepositCap) external;
  function updateFees(Fees memory _fees) external;
  function updateMarketState(ISet _set, CState _newMarketState) external;
  function updateOwner(address _newOwner) external;
  function updatePauser(address _newPauser) external;
  function updateSetOwner(ISet _set, address _owner) external;
  function updateSetPauser(ISet _set, address _pauser) external;
  function updateUserDelays(uint256 _minDepositDuration, uint256 _withdrawDelay, uint256 _purchaseDelay) external;
  function validateFees(Fees memory _fees) pure external returns (bool);
  function withdrawDelay() view external returns (uint32);
}

