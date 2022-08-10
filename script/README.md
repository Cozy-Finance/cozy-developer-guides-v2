# Cozy Scripts

This folder contains various scripts.
Some may be intended to be used locally only, others to send live transactions, and some for both.

- [Cozy Scripts](#cozy-scripts)
  - [Configuration](#configuration)
  - [Scripts](#scripts)
    - [`DeployProtectionSet.s.sol`](#deployprotectionsetssol)
    - [`UpdateConfigs.s.sol`](#updateconfigsssol)


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

- Prepend `FOUNDRY_PROFILE=lite` to each `forge script` command to significantly speed up compilation time. This turns off the solc optimizer, resulting in bigger contracts that use more gas, but for local scripts this is ok.
- Append a verbosity flag such as `-vvv` to each `forge script` command for more details.
Learn more about the verbosity options [here](https://book.getfoundry.sh/forge/tests.html#logs-and-traces). This is useful to help debug failing scripts. The sample commands below use `-vvvv` to always show the full trace.
- By default the scripts are dry runs that don't broadcast transactions to the chain. To actually submit the transactions to the specified RPC, append `--private-key <privateKey> --broadcast`

For example, if you want to use the `DeployProtectionSet` script to deploy a set to a node to facilitate frontend development and testing you should prepend `FOUNDRY_PROFILE=lite` and append `--private-key $DEPLOYER_PRIVATE_KEY --broadcast`.
When starting anvil you'll see a list of default accounts and their private keys&mdash; you can use account 9's private key for these local deploys.

**_Never use the default anvil accounts on a live network, as the private keys are publicly known and funds sent to that account will be stolen_**.

⚠️ Additionally, note that some scripts may use the [`ffi`](https://book.getfoundry.sh/cheatcodes/ffi.html) cheatcode to automatically do things like set token balances on anvil.
⚠️ This lets arbitrary commands be executed on your machine, so it's recommended to review the `ffi` usage first to ensure the script is safe.

### `DeployProtectionSet.s.sol`

*Purpose: Local deploy, testing, and production.*

This script deploys a protection set using the configured market info and set configuration.
Before executing, the configuration section in the script should be updated.

To run this script:

```sh
# Start anvil, forking from the current state of the desired chain.
anvil --fork-url $OPTIMISM_RPC_URL

# In a separate terminal, perform a dry run the script.
forge script script/DeployProtectionSet.s.sol --rpc-url "http://127.0.0.1:8545" -vvvv

# Or, to broadcast a transaction.
forge script script/DeployProtectionSet.s.sol \
  --rpc-url "http://127.0.0.1:8545" \
  --private-key $OWNER_PRIVATE_KEY \
  --broadcast \
  -vvvv
```

### `UpdateConfigs.s.sol`

*Purpose: Update set and market configurations.*

This script requires the protocol and a set to be deployed on the desired chain.
The script includes a "Configuration" section at the top, which must be updated to the desired set/market config updates.

This script behaves as follows:
- This script will queue the configured set and market config updates if they have not already been queued, or if they have and the deadline to apply them has passed.
- If the config updates have been queued and the current timestamp is within the allowed timeframe to apply queued config updates, this script will apply the queued config updates.

Running the script with config updates that have already been queued (whether or not this script was used to do so) will apply
the queued config updates if the current timestamp is within the allowed window to apply config changes and if the set is active.

To run this script:

```sh
# Start anvil, forking from the current state of the desired chain.
anvil --fork-url $OPTIMISM_RPC_URL

# In a separate terminal, perform a dry run the script.
# The private key of either the set owner or protocol owner must be included in order to queue config updates.
forge script script/UpdateConfigs.s.sol --rpc-url "http://127.0.0.1:8545" --private-key $OWNER_PRIVATE_KEY -vvvv

# Or, to broadcast a transaction.
forge script script/UpdateConfigs.s.sol \
  --rpc-url "http://127.0.0.1:8545" \
  --private-key $OWNER_PRIVATE_KEY \
  --broadcast \
  -vvvv
```