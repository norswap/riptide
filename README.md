# RIPTIDE

or

## Rationalized Item Pricing & Trading Incentivization for Decentralized Economiesgit 

RIPTIDE is a protocol for managing the distribution and inflation of digital assets.

It is particularly suited for the management of game assets, where value-accrual for early entrants
needs to be balanced with the need to keep the game affordable for new players.

In brief, RIPTIDE proposes to create bundle of assets that are sold at a protocol-defined price. The
price scales with the total asset supply.

Furthermore, to avoid rare items crushing the value of other items (as arbitrageurs create boosters
when their expected card value exceeds their sticker price), rare items have increased drop
probability, scaling sub-linearly with the price (to preserve card value).

In summary, RIPTIDE ensures that card can grow in value, while making sure that it remains possible
for newcomers to acquire rare items. In a game, these might be needed for high-level competitive
play.

## Installation

Tooling required:

- Make
- [Foundry](https://github.com/foundry-rs/foundry)
  - Last `foundryup`: 12 May 2023
- Node.js & [PNPM](https://pnpm.io/) (`npm install -g pnpm`)
  - Tested with Node v20.1.0

Run contract tests for basic sanity testing: 

- `(cd packages/contracts && make test)`

## IDEs

If you're using Visual Studio Code, the contract remappings will only be picked up if you set the
root of the project to the `contracts` package. Otherwise, you'll add to manually add the remappings
(from `remappings.txt`) to the Solidity plugin configuration.

## Running

To deploy and try out the app locally:

```shell
make dev
```

This will do the following from a single terminal (using run-pty):

- Run anvil (local EVM node) at localhost:8545 with chain ID 1337
  (this chain comes preconfigured in Metamask and other wallets as "Localhost")
- Run the NextJS dev command (web server + live reload)
- Deploy the contracts to the local node
- Build the zk circuits (this make take a while, especially the first time when you'll need to
   download the 300MB trusted setup file)

After that, you can visit the app at http://localhost:3000/ (if that port is already occupied,
NextJS might affect another one).

If your shell doesn't support run-pty, you can run the commands manually in different terminals:

```shell
make anvil
make webdev
make deploy
make circuits
```

Note: at least for me, Metamask has a bug that doesn't let the app initiate chain switching when
the target is "Localhost" (other targets work fine). If the same thing happens to you, you'll need
to switch to the Localhost chain manually within the wallet.

## Commands

See the [Makefile](/Makefile) for a description of all top-level make commands.