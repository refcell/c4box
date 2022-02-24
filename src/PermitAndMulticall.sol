// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.11;

import {IERC20Permit} from "./interfaces/IERC20Permit.sol";

/// @title Permit And Multicall
/// @author Adapted from https://github.com/pooltogether/v4-twab-delegator
/// @notice Allows a user to permit token spend and then call multiple functions on a contract.
contract PermitAndMulticall {

  /// @notice Emitted when a delegatecall fails
  /// @param returndata The returndata of the delegatecall
  error DelegateCallFailed(bytes returndata);

  /// @notice Secp256k1 signature values.
  /// @param deadline Timestamp at which the signature expires
  /// @param v `v` portion of the signature
  /// @param r `r` portion of the signature
  /// @param s `s` portion of the signature
  struct Signature {
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  /// @notice Allows a user to call multiple functions on the same contract.  Useful for EOA who want to batch transactions.
  /// @param _data An array of encoded function calls.  The calls must be abi-encoded calls to this contract.
  /// @return results The results from each function call
  function _multicall(bytes[] calldata _data) internal virtual returns (bytes[] memory results) {
    results = new bytes[](_data.length);

    // For each call, delegate and store result
    for (uint256 i = 0; i < _data.length; i++) {
      // Delegate Call
      (bool success, bytes memory returndata) = address(this).delegatecall(_data[i]);

      // Revert on unsuccessful delegatecall
      if (!success) {
        revert DelegateCallFailed(returndata);
      }

      // mstore result
      results[i] = returndata;
    }

    return results;
  }

  /// @notice Alow a user to approve ticket and run various calls in one transaction.
  /// @param _from Address of the sender
  /// @param _amount Amount of tickets to approve
  /// @param _permitSignature Permit signature
  /// @param _data Datas to call with `functionDelegateCall`
  function _permitAndMulticall(
    IERC20Permit _permitToken,
    address _from,
    uint256 _amount,
    Signature calldata _permitSignature,
    bytes[] calldata _data
  ) internal {
    _permitToken.permit(
      _from,
      address(this),
      _amount,
      _permitSignature.deadline,
      _permitSignature.v,
      _permitSignature.r,
      _permitSignature.s
    );

    _multicall(_data);
  }
}
