// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IManager {
  event AdminChanged(address previousAdmin, address newAdmin);
  event BackstopApprovalStatusUpdated(address indexed set, bool status);
  event BeaconUpgraded(address indexed beacon);
  event ConfigParamsUpdated(uint256 configUpdateDelay, uint256 configUpdateGracePeriod);
  event ConfigUpdatesFinalized(address indexed set, SetConfig setConfig, (address,address,uint16,uint16)[] marketInfos);
  event ConfigUpdatesQueued(address indexed set, SetConfig setConfig, (address,address,uint16,uint16)[] marketInfos, uint256 updateTime, uint256 updateDeadline);
  event CozyFeesClaimed(address indexed set);
  event DelaysUpdated(uint256 minDepositDuration, uint256 withdrawDelay, uint256 purchaseDelay);
  event DepositCapUpdated(address indexed asset, uint256 depositCap);
  event FeesUpdated(Fees fees);
  event MarketStateUpdated(address indexed set, address indexed trigger, uint8 indexed state);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event PauserUpdated(address indexed newPauser);
  event SetFeesClaimed(address indexed set, address _receiver);
  event SetOwnerUpdated(address indexed set, address indexed owner);
  event SetPauserUpdated(address indexed set, address indexed pauser);
  event SetStateUpdated(address indexed set, uint8 indexed state);
  event Upgraded(address indexed implementation);

  struct InactivityData { uint64 a; (uint64,uint64)[] b; }
  struct SetConfig { uint256 a; uint256 b; address c; address d; }
  struct Delays { uint256 a; uint256 b; uint256 c; uint256 d; uint256 e; }
  struct Fees { uint16 a; uint16 b; uint16 c; uint16 d; uint16 e; uint16 f; }

  function MAX_FEE() view external returns (uint256);
  function VERSION() view external returns (uint256);
  function backstop() view external returns (address);
  function cancellationFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function claimCozyFees(address[] memory _sets) external;
  function claimSetFees(address _set, address _receiver) external;
  function configUpdateDelay() view external returns (uint32);
  function configUpdateGracePeriod() view external returns (uint32);
  function createSet(address _owner, address _pauser, address _asset, SetConfig memory _setConfig, (address,address,uint16,uint16)[] memory _marketInfos, bytes32 _salt) external returns (address _set);
  function depositFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function fees() view external returns (uint16 depositFeeReserves, uint16 depositFeeBackstop, uint16 purchaseFeeReserves, uint16 purchaseFeeBackstop, uint16 cancellationFeeReserves, uint16 cancellationFeeBackstop);
  function finalizeUpdateConfigs(address _set, SetConfig memory _setConfig, (address,address,uint16,uint16)[] memory _marketInfos) external;
  function getDelayTimeAccrued(uint256 _startTime, uint256 _currentInactiveDuration, (uint64,uint64)[] memory _inactivePeriods) view external returns (uint256);
  function getDepositCap(address _asset) view external returns (uint256);
  function getMarketInactivityData(address _set, address _trigger) view external returns (InactivityData memory);
  function getWithdrawDelayTimeAccrued(address _set, uint256 _startTime, uint8 _setState) view external returns (uint256 _activeTimeElapsed);
  function inactiveDurationBeforeTimestampLookup(uint256 _timestamp, (uint64,uint64)[] memory _inactivePeriods) pure external returns (uint256);
  function initializeCount() view external returns (uint256);
  function initializeV0(address _owner, address _pauser, Delays memory _delays, Fees memory _fees) external;
  function isAnyMarketFrozen(address _set) view external returns (bool);
  function isApprovedForBackstop(address _set) view external returns (bool);
  function isLocalSetOwner(address _set, address _who) view external returns (bool);
  function isMarket(address _set, address _who) view external returns (bool);
  function isOwner(address _set, address _who) view external returns (bool);
  function isOwnerOrPauser(address _set, address _who) view external returns (bool);
  function isPauser(address _set, address _who) view external returns (bool);
  function isValidConfiguration(SetConfig memory _setConfig, (address,address,uint16,uint16)[] memory _marketInfos) pure external returns (bool);
  function isValidMarketStateTransition(address _set, address _who, uint8 _from, uint8 _to) view external returns (bool);
  function isValidSetStateTransition(address _set, address _who, uint8 _from, uint8 _to) view external returns (bool);
  function isValidUpdate(address _set, SetConfig memory _setConfig, (address,address,uint16,uint16)[] memory _marketInfos) view external returns (bool);
  function marketInactivityData(address, address) view external returns (uint64 inactiveTransitionTime);
  function minDepositDuration() view external returns (uint32);
  function owner() view external returns (address);
  function pause(address _set) external;
  function pauser() view external returns (address);
  function proxiableUUID() view external returns (bytes32);
  function ptokenFactory() view external returns (address);
  function purchaseDelay() view external returns (uint32);
  function purchaseFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);
  function queuedConfigUpdateHash(address) view external returns (bytes32);
  function setFactory() view external returns (address);
  function setInactivityData(address) view external returns (uint64 inactiveTransitionTime);
  function setOwner(address) view external returns (address);
  function setPauser(address) view external returns (address);
  function sets(address) view external returns (bool exists, bool approved, uint64 configUpdateTime, uint64 configUpdateDeadline);
  function unpause(address _set) external;
  function updateBackstopApprovals((address,bool)[] memory _approvals) external;
  function updateConfigParams(uint256 _configUpdateDelay, uint256 _configUpdateGracePeriod) external;
  function updateConfigs(address _set, SetConfig memory _setConfig, (address,address,uint16,uint16)[] memory _marketInfos) external;
  function updateDepositCap(address _asset, uint256 _newDepositCap) external;
  function updateFees(Fees memory _fees) external;
  function updateMarketState(address _set, uint8 _newMarketState) external;
  function updateOwner(address _newOwner) external;
  function updatePauser(address _newPauser) external;
  function updateSetOwner(address _set, address _owner) external;
  function updateSetPauser(address _set, address _pauser) external;
  function updateUserDelays(uint256 _minDepositDuration, uint256 _withdrawDelay, uint256 _purchaseDelay) external;
  function upgradeTo(address newImplementation) external;
  function upgradeToAndCall(address newImplementation, bytes memory data) payable external;
  function validateFees(Fees memory _fees) pure external returns (bool);
  function withdrawDelay() view external returns (uint32);
}

