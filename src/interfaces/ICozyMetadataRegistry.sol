// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "src/interfaces/ISet.sol";

/**
 * @dev Interface for interacting with the Cozy Lens. This is not a comprehensive
 * interface.
 */
interface ICozyMetadataRegistry {
  // Required metadata for a given set or trigger.
  struct Metadata {
    string name; // Name of the set or trigger.
    string description; // Description of the set or trigger.
    string logoURI; // Path to a logo for the set or trigger.
  }

  /// @notice Update metadata for a set.
  /// @param _set The address of the set.
  /// @param _metadata The new metadata for the set.
  function updateSetMetadata(ISet _set, Metadata calldata _metadata) external;

  /// @notice Update metadata for sets.
  /// @param _sets An array of sets to be updated.
  /// @param _metadata An array of new metadata, mapping 1:1 with the addresses in the _sets array.
  function updateSetMetadata(ISet[] calldata _sets, Metadata[] calldata _metadata) external;

  /// @notice Update metadata for a trigger.
  /// @param _trigger The address of the trigger.
  /// @param _metadata The new metadata for the trigger.
  function updateTriggerMetadata(address _trigger, Metadata calldata _metadata) external;

  /// @notice Update metadata for triggers.
  /// @param _triggers An array of triggers to be updated.
  /// @param _metadata An array of new metadata, mapping 1:1 with the addresses in the _triggers array.
  function updateTriggerMetadata(address[] calldata _triggers, Metadata[] calldata _metadata) external;
}