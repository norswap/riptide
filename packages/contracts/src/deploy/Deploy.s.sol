// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "multicall/Multicall3.sol";
import { ud } from "prb-math/UD60x18.sol";

import "../demo/CardCollection.sol";
import "../demo/DemoAssertionEngine.sol";
import "../BoosterManager.sol";
import "../BoostedCollection.sol";
import "../AssertionManager.sol";

contract DeployLocal is Script {
    bytes32 private constant salt = bytes32(uint256(4269));

    function run() external {
        vm.startBroadcast();

        uint16[3] memory numCardsPerRarity = [uint16(1), uint16(1), uint16(1)];
        CardTypeInfo[] memory cardTypeInfos = new CardTypeInfo[](3);
        cardTypeInfos[0] = CardTypeInfo("Alpha", "pic://alpha.png", 0, Rarity.COMMON);
        cardTypeInfos[1] = CardTypeInfo("Beta", "pic://beta.png", 0, Rarity.UNUSUAL);
        cardTypeInfos[2] = CardTypeInfo("Gamma", "pic://beta.png", 0, Rarity.RARE);

        BoosterManager.RarityClass[] memory rarityClasses = new BoosterManager.RarityClass[](3);
        // total items, items per booster, rarity ID
        rarityClasses[0] = BoosterManager.RarityClass(1, 4, 0);
        rarityClasses[1] = BoosterManager.RarityClass(1, 2, 1);
        rarityClasses[2] = BoosterManager.RarityClass(1, 1, 2);

        CardCollection cardCollection = new CardCollection(numCardsPerRarity, cardTypeInfos);

        BoosterManager boosterManager = new BoosterManager(
            BoostedCollection(cardCollection),
            ud(2), // log multiplier
            20, // target base supply
            5 gwei, // initial booster price
            rarityClasses);

        DemoAssertionEngine engine = new DemoAssertionEngine();

        AssertionManager assertionManager = new AssertionManager(boosterManager, engine);
        boosterManager.setAssertionManager(assertionManager);

        console2.log("CardCollection address", address(cardCollection));
        console2.log("BoosterManager address", address(boosterManager));
        console2.log("AssertionEngine address", address(engine));
        console2.log("AssertionManager address", address(assertionManager));

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
