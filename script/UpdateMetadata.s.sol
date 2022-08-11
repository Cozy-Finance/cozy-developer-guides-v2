pragma solidity 0.8.15;

import "forge-std/Script.sol";
import "src/interfaces/ICozyMetadataRegistry.sol";

contract UpdateMetadata is Script {

  function run() public {
    // -------------------------------
    // -------- Configuration --------
    // -------------------------------

    ICozyMetadataRegistry metadataRegistry = ICozyMetadataRegistry(address(0xBEEF));

    // Flags to specify which update transactions should be executed.
    // NOTE: If both flags are true, the private key being used to run this script must be authorized to update
    // metadata for all configured sets and triggers.
    bool updateSetMetadata = true;
    bool updateTriggerMetadata = true;

    // -------- Set Metadata --------

    ISet[] memory _sets = new ISet[](2);
    _sets[0] = ISet(address(0xBEEF));
    _sets[1] = ISet(address(0xBEEF));

    // This array should map 1:1 with the _sets array.
    ICozyMetadataRegistry.Metadata[] memory _setMetadata = new ICozyMetadataRegistry.Metadata[](2);
    _setMetadata[0] = ICozyMetadataRegistry.Metadata(
      "Mock ETH Set",
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ac semper lectus. Ut vitae scelerisque metus.",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Ethereum_logo_2014.svg/628px-Ethereum_logo_2014.svg.png"
    );
    _setMetadata[1] = ICozyMetadataRegistry.Metadata(
      "Mock USDC Set",
      "In ac ipsum ex. Duis sagittis nibh ac volutpat venenatis. In dignissim elit et consequat ullamcorper.",
      "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"
    );

    // -------- Trigger Metadata --------

    address[] memory _triggers = new address[](3);
    _triggers[0] = address(0xBEEF);
    _triggers[1] = address(0xBEEF);
    _triggers[2] = address(0xBEEF);

    // This array should map 1:1 with the _triggers array.
    ICozyMetadataRegistry.Metadata[] memory _triggerMetadata = new ICozyMetadataRegistry.Metadata[](3);
    _triggerMetadata[0] = ICozyMetadataRegistry.Metadata(
      "Mock Near",
      "Mock Protocol Protection",
      "https://cryptologos.cc/logos/near-protocol-near-logo.png"
    );
    _triggerMetadata[1] = ICozyMetadataRegistry.Metadata(
      "Mock UST",
      "Mock Peg Protection",
      "https://cryptologos.cc/logos/terra-luna-luna-logo.png"
    );
    _triggerMetadata[2] = ICozyMetadataRegistry.Metadata(
      "Mock Compound Finance",
      "Mock Protocol Protection",
      "https://cryptologos.cc/logos/compound-comp-logo.png"
    );

    // ---------------------------
    // -------- Execution --------
    // ---------------------------

    if (updateSetMetadata) {
      vm.broadcast();
      metadataRegistry.updateSetMetadata(_sets, _setMetadata);
    }

    if (updateTriggerMetadata) {
      vm.broadcast();
      metadataRegistry.updateTriggerMetadata(_triggers, _triggerMetadata);
    }
  }
}