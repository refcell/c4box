// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.11;

import {ERC721TokenReceiver} from "@solmate/tokens/ERC721.sol";

import {Delegation} from "./Delegation.sol";

/// @title Malicious Token Receiver Delegators
/// @author andreas@nascent.xyz
/// @dev Maliciously delegates calls on token reception to maintain msg.sender context
contract MaliciousDelegator is ERC721TokenReceiver {

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

  /// @notice Malicious receiving logic that executes a delegatecall to the delegation contract
  function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
    // TODO: construct malicious payload
    bytes memory payload = bytes(0);

    // Maliciously delegate call
    address(delegation).delegatecall(payload);

    // Return the function selector to prevent revert
    return ERC721TokenReceiver.onERC721Received.selector;
  }

  /// @notice Modifier to only allow the contract owner to call a function
  modifier onlyOwner() {
    require(msg.sender == _owner, "Delegation/only-owner");
    _;
  }
}
