// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

import "src/FlexibleTrigger.sol";
import "src/abstract/BaseTrigger.sol";
import "test/utils/DSTestPlus.sol";
import "test/utils/MockTrigger.sol";

contract MockTriggerSetup is DSTestPlus, ITriggerEvents, IManagerEvents {
  uint256 constant MAX_FREEZE_DURATION = 1 days;
  uint256 constant ONE_YEAR = 365.25 days;

  address boss = address(0xFACE);
  address freezer = address(0xCAFE);

  IManager manager = IManager(address(0xFEED));

  ISet set = ISet(address(0xBEEF));

  MockTrigger triggerA;

  event FreezerAdded(address freezer);

  function setUp() public virtual {
    // Mock calls to the manager that occur by these tests.
    vm.mockCall(address(manager), abi.encodeWithSelector(manager.sets.selector), abi.encode(true, true, uint64(0), uint64(0)));
    vm.mockCall(address(manager), abi.encodeWithSelector(manager.updateMarketState.selector), abi.encode(true));

    address[] memory _freezers = new address[](1);
    _freezers[0] = freezer;
    triggerA = new MockTrigger(manager, boss, _freezers, false, MAX_FREEZE_DURATION);
    vm.prank(address(manager));
    triggerA.addSet(set);

    skip(100);
  }
}

contract MockSetWithJustAManager {
  IManager public manager;
  constructor(IManager _manager) { manager = _manager; }
}

contract MockTriggerConstructor is MockTriggerSetup {
  function testFuzz_Constructor(
    address _boss,
    address[] calldata _freezers,
    bool _autoTrigger,
    uint256 _maxFreezeDuration
  ) public {
    if (_freezers.length > 0) {
      for (uint256 i = 0; i < _freezers.length; i++) {
        vm.expectEmit(false, false, false, false);
        emit FreezerAdded(_freezers[0]);
      }
    }

    MockTrigger _trigger = new MockTrigger(manager, _boss, _freezers, _autoTrigger, _maxFreezeDuration);
    vm.prank(address(manager));
    _trigger.addSet(set);

    assertEq(address(_trigger.sets(0)), address(set));
    assertEq(_trigger.boss(), _boss);
    assertEq(_trigger.isAutoTrigger(), _autoTrigger);

    for (uint256 i = 0; i < _freezers.length; i++) {
      assertTrue(_trigger.freezers(_freezers[i]));
    }
  }
}

contract MockTriggerFreeze is MockTriggerSetup {
  function test_FreezeAllowedByFreezer() public {
    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.FROZEN))
    );
    vm.expectEmit(true, true, true, true);
    emit TriggerStateUpdated(CState.FROZEN);
    vm.prank(boss);
    triggerA.freeze();

    assertEq(triggerA.state(), CState.FROZEN);
    assertEq(triggerA.freezeTime(), block.timestamp);
  }

  function test_FreezeAllowedByBoss() public {
    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.FROZEN))
    );
    vm.expectEmit(true, true, true, true);
    emit TriggerStateUpdated(CState.FROZEN);
    vm.prank(boss);
    triggerA.freeze();

    assertEq(triggerA.state(), CState.FROZEN);
    assertEq(triggerA.freezeTime(), block.timestamp);
  }

  function testFuzz_FreezeNotAllowed(address _user) public {
    vm.assume(_user != freezer && _user != boss);
    vm.expectRevert(BaseTrigger.Unauthorized.selector);
    vm.prank(_user);
    triggerA.freeze();
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }
}

contract MockTriggerPublicTrigger is MockTriggerSetup {
  function test_PublicTrigger() public {
    testFuzz_PublicTrigger(boss, MAX_FREEZE_DURATION + 1);
  }

  function testFuzz_PublicTrigger(address _who, uint256 _timeElapsed) public {
    _timeElapsed = bound(_timeElapsed, MAX_FREEZE_DURATION + 1, ONE_YEAR);
    updateTriggerState(triggerA, CState.FROZEN);
    updateFreezeTime(triggerA, block.timestamp);

    skip(_timeElapsed);
    vm.expectEmit(true, true, true, true);
    emit TriggerStateUpdated(CState.TRIGGERED);
    hoax(_who);
    triggerA.publicTrigger();
    assertEq(triggerA.state(), CState.TRIGGERED);
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }

  function test_PublicTriggerMaxFreezeTimeNotPassed() public {
    testFuzz_PublicTriggerMaxFreezeTimeNotPassed(uint16(MAX_FREEZE_DURATION));
  }

  function testFuzz_PublicTriggerMaxFreezeTimeNotPassed(uint16 _timeElapsed) public {
    vm.assume(_timeElapsed <= MAX_FREEZE_DURATION);
    updateTriggerState(triggerA, CState.FROZEN);
    updateFreezeTime(triggerA, block.timestamp);

    skip(_timeElapsed);
    vm.expectRevert(BaseTrigger.InvalidStateTransition.selector);
    triggerA.publicTrigger();
  }

  function test_PublicTriggerFromActive() public {
    skip(MAX_FREEZE_DURATION + 1);
    vm.prank(boss);
    vm.expectRevert(BaseTrigger.InvalidStateTransition.selector);
    triggerA.publicTrigger();
  }

  function test_PublicTriggerFromTriggered() public {
    updateTriggerState(triggerA, CState.TRIGGERED);

    skip(MAX_FREEZE_DURATION + 1);
    vm.expectRevert(BaseTrigger.InvalidStateTransition.selector);
    triggerA.publicTrigger();
  }

  function test_PublicTriggerAfterProgramaticCheckUpdate() public {

    // triggerA has auto toggle off.
    triggerA.updateProgrammaticCheckResponse(true);
    triggerA.runProgrammaticCheck();
    assertEq(triggerA.state(), CState.FROZEN);
    assertEq(triggerA.freezeTime(), block.timestamp);

    skip(MAX_FREEZE_DURATION + 1);
    vm.expectEmit(true, true, true, true);
    emit TriggerStateUpdated(CState.TRIGGERED);
    vm.prank(boss);
    triggerA.publicTrigger();
    assertEq(triggerA.state(), CState.TRIGGERED);
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }
}

abstract contract MockTriggerResumeAndTrigger is MockTriggerSetup {
  CState stateUnderTest;
  CState setStateUnderTest;
  bytes methodUnderTest;

  function test_ResumeAllowedByBoss() public {
    updateTriggerState(triggerA, CState.FROZEN);

    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, stateUnderTest))
    );
    vm.expectEmit(true, true, true, true);
    emit TriggerStateUpdated(stateUnderTest);
    vm.prank(boss);
    (bool ok, ) = address(triggerA).call(methodUnderTest);
    assertTrue(ok);
    assertEq(triggerA.state(), stateUnderTest);
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }

  function test_ResumeNotAllowedIfInvalidState() public {
    vm.startPrank(boss);

    vm.expectRevert(BaseTrigger.InvalidStateTransition.selector);
    (bool ok,) = address(triggerA).call(methodUnderTest); // State is ACTIVE, so this should revert.
    require(ok, "expectRevert failed");
  }

  function test_ResumeNotAllowedByFreezers() public {
    updateTriggerState(triggerA, CState.FROZEN);

    vm.prank(freezer);
    vm.expectRevert(BaseTrigger.Unauthorized.selector);
    (bool ok,) = address(triggerA).call(methodUnderTest);
    require(ok, "expectRevert failed");
  }

  function testFuzz_ResumeNotAllowed(address _user) public {
    vm.assume(_user != boss);
    updateTriggerState(triggerA, CState.FROZEN);

    vm.prank(_user);
    vm.expectRevert(BaseTrigger.Unauthorized.selector);
    (bool ok,) = address(triggerA).call(methodUnderTest);
    require(ok, "expectRevert failed");
  }
}

contract MockTriggerResume is MockTriggerResumeAndTrigger {
  function setUp() public override {
    super.setUp();
    stateUnderTest = CState.ACTIVE;
    setStateUnderTest = CState.ACTIVE;
    methodUnderTest = abi.encode(FlexibleTrigger.resume.selector);
  }
}

contract MockTriggerTrigger is MockTriggerResumeAndTrigger {
  function setUp() public override {
    super.setUp();
    stateUnderTest = CState.TRIGGERED;
    setStateUnderTest = CState.ACTIVE;
    methodUnderTest = abi.encode(FlexibleTrigger.trigger.selector);
  }
}

contract MockSetPausedTriggerStateUpdate is MockTriggerSetup {
  function test_FreezeAndResume() public {
    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.FROZEN))
    );
    vm.startPrank(boss);
    triggerA.freeze(); // Should not revert.
    assertEq(triggerA.state(), CState.FROZEN);
    assertEq(triggerA.freezeTime(), block.timestamp);

    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.ACTIVE))
    );
    triggerA.resume();
    assertEq(triggerA.state(), CState.ACTIVE);
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }

  function test_FreezeAndTrigger() public {
    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.FROZEN))
    );

    hoax(boss);
    triggerA.freeze(); // Should not revert.
    assertEq(triggerA.state(), CState.FROZEN);
    assertEq(triggerA.freezeTime(), block.timestamp);

    vm.expectCall(
      address(manager),
      abi.encodeCall(manager.updateMarketState, (set, CState.TRIGGERED))
    );
    hoax(boss);
    triggerA.trigger();
    assertEq(triggerA.state(), CState.TRIGGERED);
    assertEq(triggerA.freezeTime(), 0); // freezeTime 0 is the default state (not frozen).
  }
}