# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# Set CONFIG to "LOCAL" by default. Other valid values: "TEST" or "MAIN".
CONFIG?=LOCAL
export CONFIG

# See README.md for documentation.

setup:
	[ ! -f .env ] && cp .env.example .env
.PHONY: setup

build:
	forge build
.PHONY: build

test:
	forge test -vv
.PHONY: test

testv:
	forge test -vvvv
.PHONY: testv

test-gas:
	forge test --gas-report
.PHONY: test-gas

watch:
	forge test --watch src/
.PHONY: watch

test-fork:
	forge test --gas-report --fork-url ${ETH_NODE}
.PHONY: test-fork

clean:
	forge clean
.PHONY: clean

# The 1337 chain id matches chain.localhost in RainbowKit & "Localhost 8545" in MetaMask.
anvil:
	anvil --chain-id 1337
.PHONY: anvil

# Dumps function, event and error selectors to out/selectors.txt
selectors:
	forge upload-selectors --all > out/selectors.txt
.PHONY: selectors

deploy: build
	@forge script src/deploy/Deploy.s.sol:Deploy \
		--fork-url $(RPC_$(CONFIG)) \
		--private-key $(PRIVATE_KEY_$(CONFIG)) \
		--broadcast \
		| grep "address " > out/deployment.txt
	@cat out/deployment.txt
	@node scripts/extract_contract_addresses_abis.js \
		out/deployment.txt \
		out/abis.json \
		> out/deployment.json
.PHONY: deploy

debug-deploy:
	@forge script src/deploy/Deploy.s.sol:Deploy \
		--fork-url http://localhost:8545 \
		--private-key $(PRIVATE_KEY0) \
		--broadcast
.PHONY: debug-deploy

update-forge-std:
	rm -rf lib/forge-std
	cd lib && git clone git@github.com:foundry-rs/forge-std.git
	cd lib/forge-std && git submodule update --init --recursive
.PHONY: update-forge-std