// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IManagerEvents.sol";

interface IManager is IManagerEvents {
  /// @notice Max fee for deposit and purchase.
  function MAX_FEE() view external returns (uint256);

  /// @notice Returns the address of the Cozy protocol Backstop.
  function backstop() view external returns (address);

  /// @notice Returns the fees applied on cancellations that go to Cozy protocol reserves and backstop.
  function cancellationFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice For all specified `_sets`, transfers accrued reserve and backstop fees to the owner address and
  /// backstop address, respectively.
  function claimCozyFees(ISet[] memory _sets) external;

  /// @notice Callable by the owner of `_set` and sends accrued fees to `_receiver`.
  function claimSetFees(ISet _set, address _receiver) external;

  /// @notice Configuration updates are queued, then can be applied after this delay elapses.
  function configUpdateDelay() view external returns (uint32);

  /// @notice Once `configUpdateDelay` elapses, configuration updates must be applied before the grace period elapses.
  function configUpdateGracePeriod() view external returns (uint32);

  /// @notice Deploys a new set with the provided parameters.
  function createSet(address _owner, address _pauser, address _asset, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos, bytes32 _salt) external returns (ISet _set);

  /// @notice Returns the fees applied on deposits that go to Cozy protocol reserves and backstop.
  function depositFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice Returns protocol fees that can be applied on deposit/mint, purchase, and cancellation.
  function fees() view external returns (uint16 depositFeeReserves, uint16 depositFeeBackstop, uint16 purchaseFeeReserves, uint16 purchaseFeeBackstop, uint16 cancellationFeeReserves, uint16 cancellationFeeBackstop);

  /// @notice Execute queued updates to set config and market configs.
  function finalizeUpdateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;

  /// @notice Returns the amount of delay time that has accrued since a timestamp.
  function getDelayTimeAccrued(uint256 _startTime, uint256 _currentInactiveDuration, InactivePeriod[] memory _inactivePeriods) view external returns (uint256);

  /// @notice Returns the maximum amount of assets that can be deposited into a set that uses `_asset`.
  function getDepositCap(address _asset) view external returns (uint256);

  /// @notice Returns the amount of time that accrued towards the withdrawal delay for the `_set`, given the
  /// `_startTime` and the `_setState`.
  function getWithdrawDelayTimeAccrued(ISet _set, uint256 _startTime, uint8 _setState) view external returns (uint256 _activeTimeElapsed);

  /// @notice Returns true if there is at least one FROZEN market in the `_set`, false otherwise.
  function isAnyMarketFrozen(ISet _set) view external returns (bool);

  /// @notice Returns true if the specified `_set` is approved for the backstop, false otherwise.
  function isApprovedForBackstop(ISet _set) view external returns (bool);

  /// @notice Returns true if `_who` is the local owner for the specified `_set`, false otherwise.
  function isLocalSetOwner(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is a valid market in the `_set`, false otherwise.
  function isMarket(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy owner or the local owner for the specified `_set`, false otherwise.
  function isOwner(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy owner/pauser or the local owner/pauser for the specified `_set`,
  /// false otherwise.
  function isOwnerOrPauser(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if `_who` is the Cozy pauser or the local pauser for the specified `_set`, false otherwise.
  function isPauser(ISet _set, address _who) view external returns (bool);

  /// @notice Returns true if the provided `_setConfig` and `_marketInfos` pairing is generically valid, false otherwise.
  function isValidConfiguration(SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) pure external returns (bool);

  /// @notice Check if a state transition is valid for a market in a set.
  function isValidMarketStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);

  /// @notice Returns true if the state transition from `_from` to `_to` is valid for the given `_set` when called
  /// by `_who`, false otherwise.
  function isValidSetStateTransition(ISet _set, address _who, uint8 _from, uint8 _to) view external returns (bool);

  /// @notice Returns true if the provided `_setConfig` and `_marketInfos` pairing is valid for the `_set`,
  /// false otherwise.
  function isValidUpdate(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) view external returns (bool);

  /// @notice Minimum duration that funds must be supplied for before initiating a withdraw.
  function minDepositDuration() view external returns (uint32);

  /// @notice Pauses the set.
  function pause(ISet _set) external;

  /// @notice Duration that must elapse before purchased protection becomes active.
  function purchaseDelay() view external returns (uint32);

  /// @notice Returns the fees applied on purchases that go to Cozy protocol reserves and backstop.
  function purchaseFees() view external returns (uint256 _reserveFee, uint256 _backstopFee);

  /// @notice Maps from set address to a hash representing queued `SetConfig` and `MarketInfo[]` updates. This hash
  /// is used to prove that the `SetConfig` and `MarketInfo[]` params used when applying config updates are identical
  /// to the queued updates.
  function queuedConfigUpdateHash(address) view external returns (bytes32);

  /// @notice Returns the owner address for the given set.
  function setOwner(address) view external returns (address);

  /// @notice Returns the pauser address for the given set.
  function setPauser(address) view external returns (address);

  /// @notice For the specified set, returns whether it's a valid Cozy set, if it's approve to use the backstop,
  /// as well as timestamps for any configuration updates that are queued.
  function sets(ISet) view external returns (bool exists, bool approved, uint64 configUpdateTime, uint64 configUpdateDeadline);

  /// @notice Unpauses the set.
  function unpause(ISet _set) external;

  /// @notice Signal an update to the set config and market configs. Existing queued updates are overwritten.
  function updateConfigs(ISet _set, SetConfig memory _setConfig, MarketInfo[] memory _marketInfos) external;

  /// @notice Called by a trigger when it's state changes to `_newMarketState` to execute the corresponding state
  /// change in the market for the given `_set`.
  function updateMarketState(ISet _set, CState _newMarketState) external;

  /// @notice Updates the owner of `_set` to `_owner`.
  function updateSetOwner(ISet _set, address _owner) external;

  /// @notice Updates the pauser of `_set` to `_pauser`.
  function updateSetPauser(ISet _set, address _pauser) external;

  /// @notice Returns true if the provided `_fees` are valid, false otherwise.
  function validateFees(Fees memory _fees) pure external returns (bool);

  /// @notice Duration that must elapse before completing a withdrawal after initiating it.
  function withdrawDelay() view external returns (uint32);
}

