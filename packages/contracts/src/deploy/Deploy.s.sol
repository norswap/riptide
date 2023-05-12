// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "multicall/Multicall3.sol";

contract DeployLocal is Script {
    bytes32 private constant salt = bytes32(uint256(4269));

    function run() external {
        vm.startBroadcast();

        // MyContract contract = new MyContract();
        // contract.setInit(something);
        // console2.log("MyContract address", address(contract));

        Multicall3 multicall = new Multicall3();
        console2.log("Multicall3 address", address(multicall));

        vm.stopBroadcast();

//        string memory mnemonic = "test test test test test test test test test test test junk";
//        (address ACCOUNT0,) = deriveRememberKey(mnemonic, 0);
//        (address ACCOUNT1,) = deriveRememberKey(mnemonic, 1);
//
//        vm.broadcast(ACCOUNT0);
//        // anything called here will be executed by ACCOUNT0
//        vm.broadcast(ACCOUNT1);
//        // anything called here will be executed by ACCOUNT0
    }
}

contract DeployPublic is Script {
    bytes32 private constant salt = bytes32(uint256(4269));

    function run() external {
        vm.startBroadcast();

        // TODO CREATE2 messes up Ownable contracts, by setting owner to CREATE2 deployer

        // Using CREATE2 (specifying salt) makes deployment address predictable no matter the chain,
        // if the bytecode does not change. (Note that Foundry omits the matadata hash by default:
        // https://github.com/foundry-rs/foundry/pull/1180)

        // Not used for local deployments because it needs the CREATE2 deployer deployed at
        // 0x4e59b44847b379578588920ca78fbf26c0b4956c and that's not the case on the Anvil chain.

        vm.startBroadcast();

        // MyContract contract = new MyContract{salt: salt}();
        // contract.setInit(something);
        // console2.log("MyContract address", address(contract));

        Multicall3 multicall = new Multicall3();
        console2.log("Multicall3 address", address(multicall));

        vm.stopBroadcast();
    }
}
