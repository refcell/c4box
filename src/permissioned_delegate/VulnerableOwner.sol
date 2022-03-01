// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.12;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC721} from "@solmate/tokens/ERC721.sol";

import {Delegation} from "./Delegation.sol";
import {Delegator} from "./Delegator.sol";
import {PermitAndMulticall} from "./PermitAndMulticall.sol";


/// @title Vulnerable Owner
/// @author andreas@nascent.xyz
/// @dev This contract is the owner of Delegation instances.
/// @dev It is vulnerable to delegatecalls present when transferring ERC721 Ownership.
contract VulnerableOwner is ERC721, Delegator, PermitAndMulticall {

  /// >>>>>>>>>>>>>>>> IMMUTABLES <<<<<<<<<<<<<<<< ///

  /// @notice The contract owner
  address public owner;

  /// >>>>>>>>>>>>>>>> STORAGE <<<<<<<<<<<<<<<< ///

  uint256 public tokenId;

  /// >>>>>>>>>>>>>>>> CONSTRUCTOR <<<<<<<<<<<<<<<< ///

  /// @notice Creates a new TWAB Vulnerable Owner
  /// @param name_ The name for the staked ticket token
  /// @param symbol_ The symbol for the staked ticket token
  constructor(
    string memory name_,
    string memory symbol_
  ) Delegator() ERC721(name_, symbol_) {
    owner = msg.sender;
  }

  /// >>>>>>>>>>>>>>>>>> EXTERNAL <<<<<<<<<<<<<<<<<< ///

  /// @notice Creates a new delegation.
  /// @dev If the lock duration is non-zero lock duration, then the delegatee cannot be changed,
  /// @dev nor funding withdrawn, until the lock has expired.
  /// @dev The `_delegator` and `_slot` params are used to compute the salt of the delegation
  /// @param _delegator Address of the delegator that will be able to handle the delegation
  /// @param _slot Slot of the delegation
  /// @param _delegatee Address of the delegatee
  /// @param _lockDuration Duration of time for which the delegation is locked. Must be less than the max duration.
  /// @return Returns the address of the Delegation contract that will hold the tickets
  function createDelegation(
    address _delegator,
    uint256 _slot,
    address _delegatee,
    uint96 _lockDuration
  ) external returns (Delegation) {
    uint96 _lockUntil = computeLock(_lockDuration);
    Delegation _delegation = _createDelegation(
      _computeSalt(_delegator, bytes32(_slot)),
      _lockUntil
    );

    return _delegation;
  }

  /// >>>>>>>>>>>>>>>>>> EXPLOIT <<<<<<<<<<<<<<<<<< ///

  /// @notice Mints an ERC721 Token to the recepient
  function mint() external virtual {
    _safeMint(msg.sender, tokenId);
  }

  /// @notice Returns the URI for the given token
  function tokenURI(uint256) public pure virtual override returns (string memory) {}

  /// >>>>>>>>>>>>>>>>>> INTERNAL <<<<<<<<<<<<<<<<<< ///

  /// @notice Computes the lock using the duration and current timestamp
  /// @param _lockDuration The duration of the lock
  /// @return uint96 timestamp when the lock ends
  function computeLock(uint96 _lockDuration) internal view returns (uint96) {
    return uint96(block.timestamp) + _lockDuration;
  }
}
