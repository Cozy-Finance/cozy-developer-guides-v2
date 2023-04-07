// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ISet} from "script/interfaces/ISet.sol";

interface ICozyMetadataRegistry {
  /// @notice Required metadata for a given set.
  struct SetMetadata {
    string name; // Name of the set.
    string description; // Description of the set.
    string logoURI; // Path to a logo for the set.
  }

  /// @notice Required metadata for a given trigger.
  struct TriggerMetadata {
    string name; // Name of the trigger.
    string category; // Category of the trigger.
    string description; // Description of the trigger.
    string logoURI; // Path to a logo for the trigger.
  }

  /// @dev Emitted when a set's metadata is updated.
  event SetMetadataUpdated(address indexed set, SetMetadata metadata);

  /// @dev Emitted when a trigger's metadata is updated.
  event TriggerMetadataUpdated(address indexed trigger, TriggerMetadata metadata);

  /// @notice Address of the Cozy protocol manager.
  function manager() external view returns (address);

  /// @notice Update metadata for sets.
  /// @param sets_ An array of sets to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the _sets array.
  function updateSetMetadata(ISet[] memory sets_, SetMetadata[] memory metadata_) external;

  /// @notice Update metadata for a set.
  /// @param set_ The address of the set.
  /// @param metadata_ The new metadata for the set.
  function updateSetMetadata(ISet set_, SetMetadata memory metadata_) external;

  /// @notice Update metadata for a trigger.
  /// @param trigger_ The address of the trigger.
  /// @param metadata_ The new metadata for the trigger.
  function updateTriggerMetadata(address trigger_, TriggerMetadata memory metadata_) external;

  /// @notice Update metadata for triggers.
  /// @param triggers_ An array of triggers to be updated.
  /// @param metadata_ An array of new metadata, mapping 1:1 with the addresses in the _triggers array.
  function updateTriggerMetadata(address[] memory triggers_, TriggerMetadata[] memory metadata_) external;
}
