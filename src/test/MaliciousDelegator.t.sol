// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MaliciousDelegator} from "../permissioned_delegate/MaliciousDelegator.sol";
import {VulnerableOwner} from "../permissioned_delegate/VulnerableOwner.sol";
import {Delegation} from "../permissioned_delegate/Delegation.sol";

contract MaliciousDelegatorTest is DSTestPlus {
    MaliciousDelegator md;
    VulnerableOwner vo;
    Delegation d;

    /// @dev The mock owner of the Malicious Delegator
    address public maliciousOwner = address(69);

    /// @dev The mock owner of the vulnerable owner contract
    address public vulnerableOwner = address(1337);

    /// @dev Random delegator
    address public delegator = address(420);

    /// @notice Sets up the testing suite
    function setUp() public {
        // Create the Vulnerable owner in the context of the vulnerable owner
        startHoax(vulnerableOwner, vulnerableOwner, type(uint256).max);
        vo = new VulnerableOwner("Vulnerable", "VLNB");
        d = vo.createDelegation(
            delegator,      // delegator
            1,              // slot
            address(1),     // delegatee
            100             // lock duration
        );
        vm.stopPrank();

        // Validate VulnerableOwner
        assert(vo.owner() == vulnerableOwner);
        assert(d.owner() == address(vo));

        // Create the MaliciousDelegator from the context of the malicious owner
        startHoax(maliciousOwner, maliciousOwner, type(uint256).max);
        md = new MaliciousDelegator();
        md.setDelegation(d);
        md.setVulnerableOwner(vo);
        vm.stopPrank();

        // Validate MaliciousDelegator
        assert(md.owner() == maliciousOwner);
        assert(address(md.delegation()) == address(d));
        assert(address(md.vo()) == address(vo));
    }

    /// @notice Proof of Concept Exploit test
    function testExploit() public {
        // Call the exploit function from the owner context
        startHoax(maliciousOwner, maliciousOwner, type(uint256).max);
        vm.expectRevert(abi.encodePacked("Delegation Failed"));
        md.exploit();
        vm.stopPrank();

        // Check that the Delegation now has a changed
        // assert(d.lockUntil() == md.LOCK_UNTIL());
    }
}
