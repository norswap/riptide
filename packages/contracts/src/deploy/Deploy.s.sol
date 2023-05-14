// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "multicall/Multicall3.sol";
import {ud} from "prb-math/UD60x18.sol";

import "../demo/CardCollection.sol";
import "../demo/DemoAssertionEngine.sol";
import "../BoosterManager.sol";
import "../BoostedCollection.sol";
import "../AssertionManager.sol";

contract Deploy is Script {
    bytes32 private constant salt = bytes32(uint256(4269));

    function run() external {
        vm.startBroadcast();

        uint16[3] memory numCardsPerRarity = [uint16(7), uint16(3), uint16(2)];
        CardTypeInfo[] memory cardTypeInfos = new CardTypeInfo[](12);
        // name, URL, supply, ID, rarity
        cardTypeInfos[0] = CardTypeInfo(
            "polygon",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[1] = CardTypeInfo(
            "gnosis-chain",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[2] = CardTypeInfo(
            "1inch-network",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[3] = CardTypeInfo(
            "worldcoin",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[4] = CardTypeInfo(
            "uniswap-foundation",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[5] = CardTypeInfo(
            "lens-protocol",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );

        cardTypeInfos[6] = CardTypeInfo(
            "metamask-linea",
            "pic://common1.png",
            0,
            0,
            Rarity.COMMON
        );
        cardTypeInfos[7] = CardTypeInfo(
            "aave-grants-dao",
            "pic://unusual1.png",
            0,
            0,
            Rarity.UNUSUAL
        );
        cardTypeInfos[8] = CardTypeInfo(
            "ethereum-foundation",
            "pic://common1.png",
            0,
            0,
            Rarity.UNUSUAL
        );
        cardTypeInfos[9] = CardTypeInfo(
            "zkbob",
            "pic://common1.png",
            0,
            0,
            Rarity.UNUSUAL
        );
        cardTypeInfos[10] = CardTypeInfo(
            "apecoin-dao",
            "pic://common1.png",
            0,
            0,
            Rarity.RARE
        );
        cardTypeInfos[11] = CardTypeInfo(
            "optimism",
            "pic://common1.png",
            0,
            0,
            Rarity.RARE
        );

        BoosterManager.RarityClass[]
            memory rarityClasses = new BoosterManager.RarityClass[](3);
        // total items, items per booster, rarity ID
        rarityClasses[0] = BoosterManager.RarityClass(
            numCardsPerRarity[0],
            4,
            0
        );
        rarityClasses[1] = BoosterManager.RarityClass(
            numCardsPerRarity[1],
            2,
            1
        );
        rarityClasses[2] = BoosterManager.RarityClass(
            numCardsPerRarity[2],
            1,
            2
        );

        CardCollection cardCollection = new CardCollection(cardTypeInfos);

        BoosterManager boosterManager = new BoosterManager(
            BoostedCollection(cardCollection),
            ud(2 ether), // log multiplier
            20, // target base supply
            5 gwei, // initial booster price
            rarityClasses
        );
        cardCollection.setBoosterManager(boosterManager);

        DemoAssertionEngine engine = new DemoAssertionEngine();

        // For demo purposes, there is zero delay between the assertion and the confirmation.
        AssertionManager assertionManager = new AssertionManager(
            boosterManager,
            engine,
            0
        );
        boosterManager.setAssertionManager(assertionManager);

        uint256[][] memory prices = new uint256[][](3);
        prices[0] = new uint256[](numCardsPerRarity[0]);
        for (uint256 i = 0; i < numCardsPerRarity[0]; i++) {
            prices[0][i] = 5 gwei;
        }
        prices[1] = new uint256[](numCardsPerRarity[1]);
        for (uint256 i = 0; i < numCardsPerRarity[1]; i++) {
            prices[1][i] = 10 gwei;
        }
        prices[2] = new uint256[](numCardsPerRarity[2]);
        for (uint256 i = 0; i < numCardsPerRarity[2]; i++) {
            prices[2][i] = 20 gwei;
        }
        assertionManager.assertPrices(prices);
        assertionManager.confirmPrices();

        console2.log("CardCollection address", address(cardCollection));
        console2.log("BoosterManager address", address(boosterManager));
        console2.log("AssertionEngine address", address(engine));
        console2.log("AssertionManager address", address(assertionManager));

        //        Multicall3 multicall = new Multicall3();
        //        console2.log("Multicall3 address", address(multicall));

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
