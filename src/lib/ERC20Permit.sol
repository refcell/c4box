// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.11;

// Solmate's ERC20 implements an EIP712 Domain Separator
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {IERC20Permit} from "../interfaces/IERC20Permit.sol";

/// @title ERC20 Permit Extension
/// @author Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts
/// @dev Adds a permit method that allows for allowance changes via signatures.
/// @dev Implements https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
contract ERC20Permit is IERC20Permit, ERC20 {

  /// @dev Custom error emitted on signature expiration
  error DeadlineExpired();

  /// @dev Emitted when a signature is invalid
  error InvalidSignature();

  /// @notice A mapping of addresses to their permit nonces
  mapping(address => uint256) private _nonces;

  /// @notice Initializes the inherited ERC20
  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) ERC20(_name, _symbol, _decimals) {}

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
  ) public virtual override {
    if (block.timestamp > deadline) revert DeadlineExpired();

    uint256 curr_nonce = nonces[owner];
    nonces[owner] = curr_nonce + 1;

    // Generate Hash
    bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, curr_nonce, deadline));
    bytes32 hash = _hashTypedDataV4(structHash);

    // Recover Signature
    address signer = recover(hash, v, r, s);
    if (signer != owner) revert InvalidSignature();

    // Approve if valid
    _approve(owner, spender, value);
  }

  /// @notice Returns the current nonce for `owner`
  /// @dev Must be included whenever a signature is generated for {permit}
  /// @dev Prevents signature replay attacks
  function nonces(address owner) public view virtual override returns (uint256) {
    return _nonces[owner];
  }

  /// @notice Recovers the signer address from a split signature
  /// @dev Adapted from OZ's cryptographic `recover` function
  /// @dev https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol#L181
  function recover(
      bytes32 hash,
      uint8 v,
      bytes32 r,
      bytes32 s
  ) internal pure returns (address) {
    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      revert InvalidSignature();
    }
    if (v != 27 && v != 28) {
      revert InvalidSignature();
    }

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    if (signer == address(0)) {
      revert InvalidSignature();
    }

    // Return the recovered signer
    return recovered;
  }
}