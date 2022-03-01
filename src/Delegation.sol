// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.12;

/// @title Delegation
/// @notice A Delegation allows his owner to execute calls on behalf of the contract.
/// @author Adapted from https://github.com/pooltogether/v4-twab-delegator
/// @dev This contract pends instantiation via CREATE2 through the Delegator contract.
/// @dev Holds tickets that will be delegated to a chosen delegatee.
contract Delegation {
  /// @notice A structure to define arbitrary contract calls.
  struct Call {
    address to;
    uint256 value;
    bytes data;
  }

  /// @notice Owner Custom Error
  error OnlyOwner();

  /// @notice Already initialized custom error
  error AlreadyInitialized();

  /// @notice Contract owner.
  address public owner;

  /// @notice Timestamp until which the delegation is locked.
  uint96 public lockUntil;

  /// @notice Initializes the delegation.
  /// @param _lockUntil Timestamp until which the delegation is locked
  function initialize(uint96 _lockUntil) public {
    if (owner != address(0)) revert AlreadyInitialized();
    owner = msg.sender;
    lockUntil = _lockUntil;
  }

  /// @notice Executes calls on behalf of this contract.
  /// @param calls The array of calls to be executed
  /// @return An array of the return values for each of the calls
  function executeCalls(Call[] calldata calls) external onlyOwner returns (bytes[] memory) {
    bytes[] memory response = new bytes[](calls.length);
    for (uint256 i = 0; i < calls.length; i++) {
      response[i] = _executeCall(calls[i].to, calls[i].value, calls[i].data);
    }
    return response;
  }

  /// @notice Set the timestamp until which the delegation is locked.
  /// @param _lockUntil The timestamp until which the delegation is locked
  function setLockUntil(uint96 _lockUntil) external onlyOwner {
    lockUntil = _lockUntil;
  }

  /// @notice Executes a call to another contract.
  /// @param to The address to call
  /// @param value The Ether to pass along with the call
  /// @param data The call data
  /// @return The return data from the call
  function _executeCall(
    address to,
    uint256 value,
    bytes memory data
  ) internal returns (bytes memory) {
    (bool succeeded, bytes memory returnValue) = to.call{ value: value }(data);
    require(succeeded, string(returnValue));
    return returnValue;
  }

  /// @notice Modifier to only allow the contract owner to call a function
  modifier onlyOwner() {
    if (msg.sender != owner) revert OnlyOwner();
    _;
  }
}
