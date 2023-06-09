# RIPTIDE Contracts

## Installation

Tooling required:

- [Foundry](https://github.com/gakonst/foundry)
- Make
- Node.js & [PNPM](https://pnpm.io/) (`npm install -g pnpm`)

## Configuration

Copy `.env.example` to `.env` and customize if necessary.

By default:
- `PRIVATE_KEY0` is set the to the first Anvil devnet account (seeded by ETH)

## Commands

- `cd ../.. && make setup` - initialize libraries and npm packages
- `make setup` - copies `.env.example` to `.env` if `.env` does not exist
- `make build` - build your project
- `make test` - run tests on temp local devnet
- `make watch` - watch files and re-run tests on temp local devnet
- `make test-gas` - run tests and show gas report on temp local devnet
- `make test-fork` - run tests and show gas report using `$ETH_NODE` as RPC endpoint
- `make clean` - remove compiled files
- `make anvil` - run local Anvil devnet on port 1337
- `make deploy` - deploy the contracts on the Anvil devnet, using `$PRIVATE_KEY0` as deployer private key
  - the contract addresses are output to `out/deployment.json`
  - also updates the wagmi-generated bindings (in `packages/webapp/src/generated.ts`)
- `make selectors` - dumps to selectors for functions, events and errors to `out/selectors.txt`

## Deployments

### Goerli



### Gnosis Chain

CardCollection address 0x00fa87DBc9b5A30F8408dbd92743F018cc03CAB8
BoosterManager address 0xC837016374a6AA4B9dE49B4084580F9e6E9FcCD4
AssertionEngine address 0xdE204a7aD06EE535DFd16213cB7D9337Fbbbb04e
AssertionManager address 0xa11b763ddA1A80Ee5032079d17352C227DF257fB