// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.11;

/// @title ERC20 Permit Extension Interface
/// @author Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts
/// @dev Adds a permit method that allows for allowance changes via signatures.
/// @dev Implements https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
interface IERC20Permit {
  /// @notice Sets an account's allowance to a specified value using signatures
  /// @dev Emits an {Approval} event
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /// @notice Returns the current nonce for `owner`
  /// @dev Must be included whenever a signature is generated for {permit}
  /// @dev Prevents signature replay attacks
  function nonces(address owner) external view returns (uint256);

  /// @notice Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}