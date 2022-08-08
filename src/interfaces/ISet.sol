// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/IConfig.sol";
import "src/interfaces/ILFT.sol";
import "src/interfaces/ISetEvents.sol";
import "src/interfaces/ISetTypes.sol";

interface ISet is ILFT, ISetEvents, ISetTypes {
  /// @notice Devalues all outstanding protection by applying unaccrued decay to the specified market.
  function accrueDecay(address _trigger) external;

  /// @notice Returns the amount of assets for the Cozy backstop.
  function accruedCozyBackstopFees() view external returns (uint128);

  /// @notice Returns the amount of assets for generic Cozy reserves.
  function accruedCozyReserveFees() view external returns (uint128);

  /// @notice Returns the amount of assets accrued to the set owner.
  function accruedSetOwnerFees() view external returns (uint128);

  /// @notice Returns the amount of outstanding protection that is currently active for the specified market.
  function activeProtection(address _trigger) view external returns (uint256);

  /// @notice Returns the underlying asset used by this set.
  function asset() view external returns (address);

  /// @notice Returns the internal asset balance - equivalent to `asset.balanceOf(address(set))` if no one transfers tokens directly to the contract.
  function assetBalance() view external returns (uint128);

  /// @notice Returns the amount of assets pending withdrawal. These assets are unavailable for new protection purchases but
  /// are available to payout protection in the event of a market becoming triggered.
  function assetsPendingWithdrawal() view external returns (uint128);

  /// @notice Returns the balance of matured tokens held by `_user`.
  function balanceOfMatured(address _user) view external returns (uint256 _balance);

  /// @notice Cancel `_protection` amount of protection for the specified market, and send the refund amount to `_receiver`.
  function cancel(address _trigger, uint256 _protection, address _receiver, address _owner) external returns (uint256 _refund, uint256 _ptokens);

  /// @notice Claims protection payout after the market for `_trigger` is triggered. Pays out the specified amount of
  /// `_protection` held by `_owner` by sending it to `_receiver`.
  function claim(address _trigger, uint256 _protection, address _receiver, address _owner) external returns (uint256 _ptokens);

  /// @notice Transfers accrued reserve and backstop fees to the `_owner` address and `_backstop` address, respectively.
  function claimCozyFees(address _owner, address _backstop) external;

  /// @notice Transfers accrued set owner fees to `_receiver`.
  function claimSetFees(address _receiver) external;

  /// @notice Completes the withdraw request for the specified ID, sending the assets to the stored `_receiver` address.
  function completeRedeem(uint256 _redemptionId) external;

  /// @notice Completes the withdraw request for the specified ID, and sends assets to the new `_receiver` instead of
  /// the stored receiver.
  function completeRedeem(uint256 _redemptionId, address _receiver) external;

  /// @notice Completes the withdraw request for the specified ID, sending the assets to the stored `_receiver` address.
  function completeWithdraw(uint256 _withdrawalId) external;

  /// @notice Completes the withdraw request for the specified ID, and sends assets to the new `_receiver` instead of
  /// the stored receiver.
  function completeWithdraw(uint256 _withdrawalId, address _receiver) external;

  /// @notice The amount of `_assets` that the Set would exchange for the amount of `_shares` provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToAssets(uint256 shares) view external returns (uint256);

  /// @notice The amount of PTokens that the Vault would exchange for the amount of protection, in an ideal scenario
  /// where all the conditions are met.
  function convertToPTokens(address _trigger, uint256 _protection) view external returns (uint256);

  /// @notice The amount of protection that the Vault would exchange for the amount of PTokens, in an ideal scenario
  /// where all the conditions are met.
  function convertToProtection(address _trigger, uint256 _ptokens) view external returns (uint256);

  /// @notice The amount of `_shares` that the Set would exchange for the amount of `_assets` provided, in an ideal
  /// scenario where all the conditions are met.
  function convertToShares(uint256 assets) view external returns (uint256);

  /// @notice Returns the cost factor when purchasing the specified amount of `_protection` in the given market.
  function costFactor(address _trigger, uint256 _protection) view external returns (uint256 _costFactor);

  /// @notice Returns the current drip rate for the set.
  function currentDripRate() view external returns (uint256);

  /// @notice Returns the active protection, decay rate, and last decay time. The response is encoded into a word.
  function dataApd(address) view external returns (bytes32);

  /// @notice Returns the state and PToken address for a market, and the state for the set. The response is encoded into a word.
  function dataSp(address) view external returns (bytes32);

  /// @notice Returns the address of the set's decay model. The decay model governs how fast outstanding protection loses it's value.
  function decayModel() view external returns (address);

  /// @notice Supply protection by minting `_shares` shares to `_receiver` by depositing exactly `_assets` amount of
  /// underlying tokens.
  function deposit(uint256 _assets, address _receiver) external returns (uint256 _shares);

  /// @notice Returns the fee charged by the Set owner on deposits.
  function depositFee() view external returns (uint256);

  /// @notice Returns the market's reserve fee, backstop fee, and set owner fee applied on deposit.
  function depositFees() view external returns (uint256 _reserveFee, uint256 _backstopFee, uint256 _setOwnerFee);

  /// @notice Drip accrued fees to suppliers.
  function drip() external;

  /// @notice Returns the address of the set's drip model. The drip model governs the interest rate earned by depositors.
  function dripModel() view external returns (address);

  /// @notice Returns the array of metadata for all tokens minted to `_user`.
  function getMints(address _user) view external returns (MintMetadata[] memory);

  /// @notice Replaces the constructor to initialize the Set contract.
  function initialize(address _asset, uint256 _leverageFactor, uint256 _depositFee, address _decayModel, address _dripModel, IConfig.MarketInfo[] memory _marketInfos) external;

  /// @dev Returns the number of times the contract has been initialized. This starts at zero, and is incremented with each
  // upgrade's new initializer method.
  function initializeCount() view external returns (uint256);

  /// @notice Returns true if `_who` is a valid market in the `_set`, false otherwise.
  function isMarket(address _who) view external returns (bool);

  /// @notice Returns the drip rate used during the most recent `drip()`.
  function lastDripRate() view external returns (uint96);

  /// @notice Returns the timestamp of the most recent `drip()`.
  function lastDripTime() view external returns (uint32);

  /// @notice Returns the exchange rate of shares:assets when the most recent trigger occurred, or 0 if no market is triggered.
  /// This exchange rate is used for any pending withdrawals that were queued before the trigger occurred to calculate
  /// the new amount of assets to be received when the withdrawal is completed.
  function lastTriggeredExchangeRate() view external returns (uint192);

  /// @notice Returns the pending withdrawal count when the most recently triggered market became triggered, or 0 if none.
  /// Any pending withdrawals with IDs less than this need to have their amount of assets updated to reflect the exchange
  /// rate at the time when the most recently triggered market became triggered.
  function lastTriggeredPendingWithdrawalCount() view external returns (uint64);

  /// @notice Returns the leverage factor of the set, as a zoc.
  function leverageFactor() view external returns (uint256);

  /// @notice Returns the address of the Cozy protocol Manager.
  function manager() view external returns (address);

  /// @notice Returns the encoded market configuration, i.e. it's cost model, weight, and purchase fee for a market.
  function marketConfig(address) view external returns (bytes32);

  /// @notice Returns the maximum amount of the underlying asset that can be deposited to supply protection.
  function maxDeposit(address) view external returns (uint256);

  /// @notice Maximum amount of shares that can be minted to supply protection.
  function maxMint(address) view external returns (uint256);

  /// @notice Returns the maximum amount of protection that can be sold for the specified market.
  function maxProtection(address _trigger) view external returns (uint256);

  /// @notice Maximum amount of protection that can be purchased from the specified market.
  function maxPurchaseAmount(address _trigger) view external returns (uint256 _protection);

  /// @notice Maximum amount of Set shares that can be redeemed from the `_owner` balance in the Set,
  /// through a redeem call.
  function maxRedemptionRequest(address _owner) view external returns (uint256);

  /// @notice Maximum amount of the underlying asset that can be withdrawn from the `_owner` balance in the Set,
  /// through a withdraw call.
  function maxWithdrawalRequest(address _owner) view external returns (uint256);

  /// @notice Supply protection by minting exactly `_shares` shares to `_receiver` by depositing `_assets` amount
  /// of underlying tokens.
  function mint(uint256 _shares, address _receiver) external returns (uint256 _assets);

  /// @notice Mapping from user address to all of their mints.
  function mints(address, uint256) view external returns (uint128 amount, uint64 time, uint64 delay);

  /// @notice Returns the amount of decay that will accrue next time `accrueDecay()` is called for the market.
  function nextDecayAmount(address _trigger) view external returns (uint256 _accruedDecay);

  /// @notice Returns the amount to be dripped on the next `drip()` call.
  function nextDripAmount() view external returns (uint256);

  /// @notice Returns the number of frozen markets in the set.
  function numFrozenMarkets() view external returns (uint256);

  /// @notice Returns the number of markets in this Set, including triggered markets.
  function numMarkets() view external returns (uint256);

  /// @notice Returns the number of triggered markets in the set.
  function numTriggeredMarkets() view external returns (uint256);

  /// @notice Pauses the set.
  function pause() external;

  /// @notice Claims protection payout after the market for `_trigger` is triggered. Burns the specified number of
  /// `ptokens` held by `_owner` and sends the payout to `_receiver`.
  function payout(address _trigger, uint256 _ptokens, address _receiver, address _owner) external returns (uint256 _protection);

  /// @notice Returns the total number of withdrawals that have been queued, including pending withdrawals that have been completed.
  function pendingWithdrawalCount() view external returns (uint64);

  /// @notice Returns all withdrawal data for the specified withdrawal ID.
  function pendingWithdrawalData(uint256 _withdrawalId) view external returns (uint256 _remainingWithdrawalDelay, PendingWithdrawal memory _pendingWithdrawal);

  /// @notice Maps a withdrawal ID to information about the pending withdrawal.
  function pendingWithdrawals(uint256) view external returns (uint128 shares, uint128 assets, address owner, uint64 queueTime, address receiver, uint64 delay);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their cancellation (i.e. view the refund
  /// amount, number of PTokens burned, and associated fees collected by the protocol) at the current block, given
  /// current on-chain conditions.
  function previewCancellation(address _trigger, uint256 _protection) view external returns (uint256 _refund, uint256 _ptokens, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets);

  /// @notice Returns the utilization ratio of the specified market after canceling `_assets` of protection.
  function previewCancellationUtilization(address _trigger, uint256 _assets) view external returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their claim (i.e. view the quantity of
  /// PTokens burned) at the current block, given current on-chain conditions.
  function previewClaim(address _trigger, uint256 _protection) view external returns (uint256 _ptokens);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit (i.e. view the number of
  /// shares received) at the current block, given current on-chain conditions.
  function previewDeposit(uint256 _assets) view external returns (uint256 _shares);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit (i.e. view the number of
  /// shares received along with associated fees) at the current block, given current on-chain conditions.
  function previewDepositData(uint256 _assets) view external returns (uint256 _userShares, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets, uint256 _setOwnerFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint (i.e. view the number of
  /// assets transferred) at the current block, given current on-chain conditions.
  function previewMint(uint256 _shares) view external returns (uint256 _assets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint (i.e. view the number of
  /// assets transferred along with associated fees) at the current block, given current on-chain conditions.
  function previewMintData(uint256 _shares) view external returns (uint256 _assets, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets, uint256 _setOwnerFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their payout (i.e. view the amount of
  /// assets that would be received for an amount of PTokens) at the current block, given current on-chain conditions.
  function previewPayout(address _trigger, uint256 _ptokens) view external returns (uint256 _protection);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their purchase (i.e. view the total cost,
  /// inclusive of fees, and the number of PTokens received) at the current block, given current on-chain conditions.
  function previewPurchase(address _trigger, uint256 _protection) view external returns (uint256 _totalCost, uint256 _ptokens);

  /// @notice Allows an on-chain or off-chain user to comprehensively simulate the effects of their purchase at the
  /// current block, given current on-chain conditions. This is similar to `previewPurchase` but additionally returns
  /// the cost before fees, as well as the fee breakdown.
  function previewPurchaseData(address _trigger, uint256 _protection) view external returns (uint256 _totalCost, uint256 _ptokens, uint256 _cost, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets, uint256 _setOwnerFeeAssets);

  /// @notice Returns the utilization ratio of the specified market after purchasing `_assets` of protection.
  function previewPurchaseUtilization(address _trigger, uint256 _assets) view external returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their redemption (i.e. view the number
  /// of assets received) at the current block, given current on-chain conditions.
  function previewRedeem(uint256 shares) view external returns (uint256);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their sale (i.e. view the refund amount,
  /// protection sold, and fees accrued by the protocol) at the current block, given current on-chain conditions.
  function previewSale(address _trigger, uint256 _ptokens) view external returns (uint256 _refund, uint256 _protection, uint256 _reserveFeeAssets, uint256 _backstopFeeAssets);

  /// @notice Allows an on-chain or off-chain user to simulate the effects of their withdrawal (i.e. view the number of
  /// shares burned) at the current block, given current on-chain conditions.
  function previewWithdraw(uint256 assets) view external returns (uint256);

  /// @notice Return the PToken address for the given market.
  function ptoken(address _who) view external returns (address _ptoken);

  /// @notice Returns the address of the Cozy protocol PTokenFactory.
  function ptokenFactory() view external returns (address);

  /// @notice Purchase `_protection` amount of protection for the specified market, and send the PTokens to `_receiver`.
  function purchase(address _trigger, uint256 _protection, address _receiver) external returns (uint256 _totalCost, uint256 _ptokens);

  /// @notice Returns the market's reserve fee, backstop fee, and set owner fee applied on purchase.
  function purchaseFees(address _trigger) view external returns (uint256 _reserveFee, uint256 _backstopFee, uint256 _setOwnerFee);

  /// @notice Burns exactly `_shares` from owner and queues `_assets` amount of underlying tokens to be sent to
  /// `_receiver` after the `manager.withdrawDelay()` has elapsed.
  function redeem(uint256 _shares, address _receiver, address _owner) external returns (uint256 _assets);

  /// @notice Returns the refund factor when canceling the specified amount of `_protection` in the given market.
  function refundFactor(address _trigger, uint256 _protection) view external returns (uint256 _refundFactor);

  /// @notice Returns the amount of protection currently available to purchase for the specified market.
  function remainingProtection(address _trigger) view external returns (uint256);

  /// @notice Sell `_ptokens` amount of ptokens for the specified market, and send the refund amount to `_receiver`.
  function sell(address _trigger, uint256 _ptokens, address _receiver, address _owner) external returns (uint256 _refund, uint256 _protection);

  /// @notice Returns the shortfall (i.e. the amount of unbacked active protection) in a market, or zero if the market
  /// is fully backed.
  function shortfall(address _trigger) view external returns (uint256);

  /// @notice Returns the state of the market or set. Pass a market address to read that market's state, or the set's
  /// address to read the set's state.
  function state(address _who) view external returns (uint8 _state);

  /// @notice Total amount of fees available to drip to suppliers. When protection is purchased, this gets
  /// incremented by the protection cost (after fees). It gets decremented when fees are dripped to suppliers.
  function supplierFeePool() view external returns (uint128);

  /// @notice Syncs the internal accounting balance with the true balance.
  function sync() external;

  /// @notice Returns the total amount of assets that is available to back protection.
  function totalAssets() view external returns (uint256 _protectableAssets);

  /// @notice Array of trigger addresses used for markets in the set.
  function triggers(uint256) view external returns (address);

  /// @notice Unpauses the set and transitions to the provided `_state`.
  function unpause(uint8 _state) external;

  /// @notice Execute queued updates to setConfig and marketConfig. This should only be called by the Manager.
  function updateConfigs(uint256 _leverageFactor, uint256 _depositFee, address _decayModel, address _dripModel, IConfig.MarketInfo[] memory _marketInfos) external;

  /// @notice Updates the state of the a market in the set.
  function updateMarketState(address _trigger, uint8 _newState) external;

  /// @notice Updates the set's state to `_state.
  function updateSetState(uint8 _state) external;

  /// @notice Returns the current utilization ratio of the specified market, as a wad.
  function utilization(address _trigger) view external returns (uint256);

  /// @notice Returns the current utilization ratio of the set, as a wad.
  function utilization() view external returns (uint256);

  /// @notice Burns `_shares` from owner and queues exactly `_assets` amount of underlying tokens to be sent to
  /// `_receiver` after the `manager.withdrawDelay()` has elapsed.
  function withdraw(uint256 _assets, address _receiver, address _owner) external returns (uint256 _shares);
}