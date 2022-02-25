// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.11;

import {Bytes32AddressLib} from "@solmate/utils/Bytes32AddressLib.sol";

import {Delegation} from "./Delegation.sol";

/// @title The Delegator allows users to create delegations very cheaply.
contract Delegator {
  using Bytes32AddressLib for address;
  using Bytes32AddressLib for bytes32;

  /// @notice The instance to which all proxies will point.
  Delegation public delegationInstance;

  /// @notice Contract constructor.
  constructor() {
    delegationInstance = new Delegation();
    delegationInstance.initialize(uint96(0));
  }

  /// @notice Creates a clone of the delegation.
  /// @param _salt Random number used to deterministically deploy the clone
  /// @param _lockUntil Timestamp until which the delegation is locked
  /// @return The newly created delegation
  function _createDelegation(bytes32 _salt, uint96 _lockUntil) internal returns (Delegation) {
    Delegation _delegation = new Delegation{salt: _salt}();
    _delegation.initialize(_lockUntil);
    return _delegation;
  }

  /// @notice Computes the address of a clone, also known as minimal proxy contract.
  /// @param _salt Random number used to compute the address
  /// @return Address at which the clone will be deployed
  function _computeAddress(bytes32 _salt) internal view returns (address) {
    return keccak256(
      abi.encodePacked(
        // Prefix:
        bytes1(0xFF),
        // Creator:
        address(this),
        // Salt:
        _salt,
        // Bytecode hash:
        keccak256(
          abi.encodePacked(
            // Deployment bytecode:
            type(Delegation).creationCode
            // No constructor arguments
          )
        )
      )
    ).fromLast20Bytes(); // Convert the CREATE2 hash into an address.
  }

  /// @notice Computes salt used to deterministically deploy a clone.
  /// @param _delegator Address of the delegator
  /// @param _slot Slot of the delegation
  /// @return Salt used to deterministically deploy a clone.
  function _computeSalt(address _delegator, bytes32 _slot) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_delegator, _slot));
  }

  /// @notice Returns if a Delegation at an address has already been deployed.
  /// @param delegation The address of a Delegation which may not have been deployed yet.
  /// @return A boolean indicating whether the Delegation has been deployed already.
  function isDelegationDeployed(Delegation delegation) external view returns (bool) {
      return address(delegation).code.length > 0;
  }
}
