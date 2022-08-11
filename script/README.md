# Cozy Scripts

This folder contains various scripts.
Some may be intended to be used locally only, others to send live transactions, and some for both.

- [Cozy Scripts](#cozy-scripts)
  - [Configuration](#configuration)
  - [Scripts](#scripts)
    - [`DeployProtectionSet.s.sol`](#deployprotectionsetssol)
    - [`UpdateConfigs.s.sol`](#updateconfigsssol)
    - [`UpdateMetadata.s.sol`](#updatemetadatassol)


## Configuration

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
2. Run `foundryup` to update to the latest Foundry version.
3. Define an environment variable `<CHAIN>_RPC_URL` that points to your desired chain's RPC URL.
It's recommended to define this in your `~/.zshrc` or equivalent so it's always available.

The below steps are optional, but will let you switch your installed foundry version to an arbitrary PR, which is useful for testing features and bug fixes.

1. Install the [rust toolchain](https://www.rust-lang.org/tools/install)
2. Switch to the rust nightly (used by Foundry) by running `rustup default nightly`

## Scripts

Explanations and instructions for all scripts are below. All scripts support the following options:

- Append a verbosity flag such as `-vvv` to each `forge script` command for more details.
Learn more about the verbosity options [here](https://book.getfoundry.sh/forge/tests.html#logs-and-traces). This is useful to help debug failing scripts. The sample commands below use `-vvvv` to always show the full trace.
- By default the scripts are dry runs that don't broadcast transactions to the chain. To actually submit the transactions to the specified RPC, append `--private-key <privateKey> --broadcast`

For example, if you want to use the `DeployProtectionSet` script to deploy a set to a node to facilitate frontend development and testing you should append `--private-key $DEPLOYER_PRIVATE_KEY --broadcast`.
When starting anvil you'll see a list of default accounts and their private keys&mdash; you can use account 9's private key for these local deploys.

**_Never use the default anvil accounts on a live network, as the private keys are publicly known and funds sent to that account will be stolen_**.

⚠️ Additionally, note that some scripts may use the [`ffi`](https://book.getfoundry.sh/cheatcodes/ffi.html) cheatcode to automatically do things like set token balances on anvil.
⚠️ This lets arbitrary commands be executed on your machine, so it's recommended to review the `ffi` usage first to ensure the script is safe.

