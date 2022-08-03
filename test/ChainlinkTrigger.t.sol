// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

import "src/interfaces/IManagerTypes.sol";
import "src/ChainlinkTrigger.sol";
import "src/interfaces/ICState.sol";
import "test/utils/DSTestPlus.sol";
import "test/utils/MockChainlinkOracle.sol";

contract MockManager is ICState {
  // Any set you ask about is managed by this contract \o/.
  function sets(ISet /* set */) external pure returns(IManagerTypes.SetData memory) {
    return IManagerTypes.SetData(true, true, uint64(0), uint64(0));
  }

  // This can just be a no-op for the test.
  function updateMarketState(ISet /* the set */, CState /* new state */) external {}
}

contract MockChainlinkTrigger is ChainlinkTrigger {
  constructor(
    IManager _manager,
    AggregatorV3Interface _truthOracle,
    AggregatorV3Interface _targetOracle,
    uint256 _priceTolerance,
    uint256 _frequencyTolerance
  ) ChainlinkTrigger(_manager, _truthOracle, _targetOracle, _priceTolerance, _frequencyTolerance) {}

  function TEST_HOOK_programmaticCheck() public view returns (bool) { return programmaticCheck(); }

  function TEST_HOOK_setState(CState _newState) public { state = _newState; }
}

abstract contract ChainlinkTriggerUnitTest is ICState, DSTestPlus {
  uint256 constant basePrice = 1945400000000; // The answer for BTC/USD at block 15135183.
  uint256 priceTolerance = 0.15e18; // 15%.
  uint256 frequencyTolerance = 60;

  MockChainlinkTrigger trigger;
  MockChainlinkOracle truthOracle;
  MockChainlinkOracle targetOracle;
  ISet constant set = ISet(address(42));

  function setUp() public {
    IManager _manager = IManager(address(new MockManager()));

    truthOracle = new MockChainlinkOracle(basePrice);
    targetOracle = new MockChainlinkOracle(1947681501285); // The answer for WBTC/USD at block 15135183.

    trigger = new MockChainlinkTrigger(
      _manager,
      truthOracle,
      targetOracle,
      priceTolerance,
      frequencyTolerance
    );

    vm.prank(address(_manager));
    trigger.addSet(set);
  }
}

contract RunProgrammaticCheckTest is ChainlinkTriggerUnitTest {
  using FixedPointMathLib for uint256;

  function runProgrammaticCheckAssertions(uint256 _targetPrice, CState _expectedTriggerState) public {
    // ISetup.
    trigger.TEST_HOOK_setState(CState.ACTIVE);
    targetOracle.TEST_HOOK_setPrice(_targetPrice);

    // Exercise.
    if (_expectedTriggerState == CState.TRIGGERED) {
      vm.expectCall(
        address(trigger.manager()),
        abi.encodeCall(IManager.updateMarketState, (set, CState.TRIGGERED))
      );
    }
    assertEq(trigger.runProgrammaticCheck(), _expectedTriggerState);
    assertEq(trigger.state(), _expectedTriggerState);
  }

  function test_RunProgrammaticCheckUpdatesTriggerState() public {
    uint256 _overBaseOutsideTolerance = basePrice.mulWadDown(1e18 + priceTolerance) + 1;
    runProgrammaticCheckAssertions(_overBaseOutsideTolerance, CState.TRIGGERED);

    uint256 _overBaseAtTolerance = basePrice.mulWadDown(1e18 + priceTolerance);
    runProgrammaticCheckAssertions(_overBaseAtTolerance, CState.ACTIVE);

    uint256 _overBaseWithinTolerance = basePrice.mulWadDown(1e18 + priceTolerance) - 1;
    runProgrammaticCheckAssertions(_overBaseWithinTolerance, CState.ACTIVE);

    runProgrammaticCheckAssertions(basePrice, CState.ACTIVE); // At base exactly.

    uint256 _underBaseWithinTolerance = basePrice.mulWadDown(1e18 - priceTolerance) + 1;
    runProgrammaticCheckAssertions(_underBaseWithinTolerance, CState.ACTIVE);

    uint256 _underBaseAtTolerance = basePrice.mulWadDown(1e18 - priceTolerance);
    runProgrammaticCheckAssertions(_underBaseAtTolerance, CState.ACTIVE);

    uint256 _underBaseOutsideTolerance = basePrice.mulWadDown(1e18 - priceTolerance) - 1;
    runProgrammaticCheckAssertions(_underBaseOutsideTolerance, CState.TRIGGERED);
  }
}

contract ProgrammaticCheckTest is ChainlinkTriggerUnitTest {
  using FixedPointMathLib for uint256;

  function test_ProgrammaticCheckAtDiscretePoints() public {
    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 + priceTolerance) + 1); // Over base outside tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), true);

    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 + priceTolerance)); // Over base at tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 + priceTolerance) - 1); // Over base within tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    targetOracle.TEST_HOOK_setPrice(basePrice); // At base exactly.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 - priceTolerance) + 1); // Under base within tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 - priceTolerance)); // Under base at tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    targetOracle.TEST_HOOK_setPrice(basePrice.mulWadDown(1e18 - priceTolerance) - 1); // Under base outside tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), true);
  }

  function test_TruthOracleZeroPrice() public {
    truthOracle.TEST_HOOK_setPrice(0);
    assertEq(trigger.TEST_HOOK_programmaticCheck(), true);
  }

  function testFuzz_ProgrammaticCheckRevertsIfUpdatedAtExceedsBlockTimestamp(
    uint256 _truthOracleUpdatedAt,
    uint256 _targetOracleUpdatedAt
  ) public {
    uint256 _currentTimestamp = 165738985; // When this test was written.
    // Warp to the current timestamp to avoid Arithmetic over/underflow with dates.
    vm.warp(_currentTimestamp);

    _truthOracleUpdatedAt = bound(
      _truthOracleUpdatedAt,
      block.timestamp - frequencyTolerance,
      block.timestamp + 1 days
    );
    _targetOracleUpdatedAt = bound(
      _targetOracleUpdatedAt,
      block.timestamp - frequencyTolerance,
      block.timestamp + 1 days
    );

    truthOracle.TEST_HOOK_setUpdatedAt(_truthOracleUpdatedAt);
    targetOracle.TEST_HOOK_setUpdatedAt(_targetOracleUpdatedAt);

    if ( _truthOracleUpdatedAt > block.timestamp || _targetOracleUpdatedAt > block.timestamp) {
      vm.expectRevert(ChainlinkTrigger.InvalidTimestamp.selector);
    }

    trigger.TEST_HOOK_programmaticCheck();
  }

  function testFuzz_ProgrammaticCheckRevertsIfEitherOraclePriceIsStale(
    uint256 _truthOracleUpdatedAt,
    uint256 _targetOracleUpdatedAt
  ) public {
    uint256 _currentTimestamp = 165738985; // When this test was written.
    _truthOracleUpdatedAt = bound(_truthOracleUpdatedAt, 0, _currentTimestamp);
    _targetOracleUpdatedAt = bound(_targetOracleUpdatedAt, 0, _currentTimestamp);

    truthOracle.TEST_HOOK_setUpdatedAt(_truthOracleUpdatedAt);
    targetOracle.TEST_HOOK_setUpdatedAt(_targetOracleUpdatedAt);

    vm.warp(_currentTimestamp);
    if (
      _truthOracleUpdatedAt + frequencyTolerance < block.timestamp ||
        _targetOracleUpdatedAt + frequencyTolerance < block.timestamp
    ) {
      vm.expectRevert(ChainlinkTrigger.StaleOraclePrice.selector);
    }
    trigger.TEST_HOOK_programmaticCheck();
  }
}

abstract contract PegProtectionTriggerUnitTest is ICState, DSTestPlus {
  MockChainlinkOracle truthOracle;
  MockChainlinkOracle trackingOracle;
  MockChainlinkTrigger trigger;
  uint256 frequencyTolerance = 3600; // 1 hour frequency tolerance.

  ISet constant set = ISet(address(42));

  function setUp() public {
    IManager _manager = IManager(address(new MockManager()));

    truthOracle = new MockChainlinkOracle(1e8); // A $1 peg.
    trackingOracle = new MockChainlinkOracle(1e8);

    trigger = new MockChainlinkTrigger(
      _manager,
      truthOracle,
      trackingOracle,
      0.05e18, // 5% price tolerance.
      frequencyTolerance
    );
    vm.prank(address(_manager));
    trigger.addSet(set);
  }
}

contract PegProtectionRunProgrammaticCheckTest is PegProtectionTriggerUnitTest {

  function runProgrammaticCheckAssertions(uint256 _price, CState _expectedTriggerState) public {
    // ISetup.
    trigger.TEST_HOOK_setState(CState.ACTIVE);
    trackingOracle.TEST_HOOK_setPrice(_price);

    // Exercise.
    if (_expectedTriggerState == CState.TRIGGERED) {
      vm.expectCall(
        address(trigger.manager()),
        abi.encodeCall(IManager.updateMarketState, (set, CState.TRIGGERED))
      );
    }
    assertEq(trigger.runProgrammaticCheck(), _expectedTriggerState);
    assertEq(trigger.state(), _expectedTriggerState);
  }

  function test_RunProgrammaticCheckUpdatesTriggerState() public {
    runProgrammaticCheckAssertions(130000000, CState.TRIGGERED); // Over peg outside tolerance.
    runProgrammaticCheckAssertions(104000000, CState.ACTIVE); // Over peg but within tolerance.
    runProgrammaticCheckAssertions(105000000, CState.ACTIVE); // Over peg at tolerance.
    runProgrammaticCheckAssertions(100000000, CState.ACTIVE); // At peg exactly.
    runProgrammaticCheckAssertions(96000000, CState.ACTIVE); // Under peg but within tolerance.
    runProgrammaticCheckAssertions(95000000, CState.ACTIVE); // Under peg at tolerance.
    runProgrammaticCheckAssertions(90000000, CState.TRIGGERED); // Under peg outside tolerance.
  }
}

contract PegProtectionProgrammaticCheckTest is PegProtectionTriggerUnitTest {

  function test_ProgrammaticCheckAtDiscretePoints() public {
    trackingOracle.TEST_HOOK_setPrice(130000000); // Over peg outside tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), true);

    trackingOracle.TEST_HOOK_setPrice(104000000); // Over peg but within tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    trackingOracle.TEST_HOOK_setPrice(105000000); // Over peg at tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    trackingOracle.TEST_HOOK_setPrice(1e8); // At peg exactly.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    trackingOracle.TEST_HOOK_setPrice(96000000); // Under peg but within tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    trackingOracle.TEST_HOOK_setPrice(95000000); // Under peg at tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), false);

    trackingOracle.TEST_HOOK_setPrice(90000000); // Under peg outside tolerance.
    assertEq(trigger.TEST_HOOK_programmaticCheck(), true);
  }
}
