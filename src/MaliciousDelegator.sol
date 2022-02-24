// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./Delegation.sol";

/// @title Malicious Token Receiver Delegators
/// @author andreas@nascent.xyz
/// @dev Maliciously delegates calls on token reception to maintain msg.sender context
contract MaliciousDelegator {

  /// @dev The Delegation contract we want to exploit
  Delegation public delegation;

  /// @notice The contract owner
  address public owner;

  /// @notice Constructs the Malicious Delegator
  constructor() public {
    owner = msg.sender;
  }

  /// @notice Allows the owner to set the delegation contract address
  function setDelegation(Delegation d) external onlyOwner {
    delegation = d;
  }

  /// @notice Receive Tokens
  // TODO:

  /// @notice Modifier to only allow the contract owner to call a function
  modifier onlyOwner() {
    require(msg.sender == _owner, "Delegation/only-owner");
    _;
  }
}
