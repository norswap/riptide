// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import { ud } from "prb-math/UD60x18.sol";

import "../demo/CardCollection.sol";
import "../demo/DemoAssertionEngine.sol";
import "../BoosterManager.sol";
import "../BoostedCollection.sol";
import "../AssertionManager.sol";

contract Integration is Test {

    CardTypeInfo[] private cardTypeInfos;

    CardCollection private cardCollection;
    BoosterManager private boosterManager;
    DemoAssertionEngine private engine;
    AssertionManager private assertionManager;

    function setUp() public {
        uint16[3] memory numCardsPerRarity = [uint16(1), uint16(1), uint16(1)];

        // name, URL, supply, ID, rarity
        cardTypeInfos.push(CardTypeInfo("Alpha", "pic://alpha.png", 0, 0, Rarity.COMMON));
        cardTypeInfos.push(CardTypeInfo("Beta", "pic://beta.png", 0, 1, Rarity.UNUSUAL));
        cardTypeInfos.push(CardTypeInfo("Gamma", "pic://gamma.png", 0, 2, Rarity.RARE));

        BoosterManager.RarityClass[] memory rarityClasses = new BoosterManager.RarityClass[](3);
        // total items, items per booster, rarity ID
        rarityClasses[0] = BoosterManager.RarityClass(1, 4, 0);
        rarityClasses[1] = BoosterManager.RarityClass(1, 2, 1);
        rarityClasses[2] = BoosterManager.RarityClass(1, 1, 2);

        cardCollection = new CardCollection(numCardsPerRarity, cardTypeInfos);

        boosterManager = new BoosterManager(
            BoostedCollection(cardCollection),
            ud(2), // log multiplier
            20, // target base supply
            5 gwei, // initial booster price
            rarityClasses);

        engine = new DemoAssertionEngine();

        assertionManager = new AssertionManager(boosterManager, engine, 0);
        boosterManager.setAssertionManager(assertionManager);

        uint256[][] memory prices = new uint256[][](3);
        prices[0] = new uint256[](1);
        prices[0][0] = 5 gwei;
        prices[1] = new uint256[](1);
        prices[1][0] = 10 gwei;
        prices[2] = new uint256[](1);
        prices[2][0] = 20 gwei;
        assertionManager.assertPrices(prices);
        console2.log("before");
        assertionManager.confirmPrices();
        console2.log("after");
    }

    // Same signature as BoosterManager.BoosterPurchased.
    event BoosterPurchased(address indexed buyer, uint256 price, uint256[] itemIDs);

    function testIntegration() public {
        assertEq(boosterManager.boosterPrice(), 5 gwei);
        vm.deal(msg.sender, 5 ether);
        // event BoosterPurchased(address indexed buyer, uint256 price, uint256[] itemIDs);
        vm.expectEmit(true, true, false, false, address(boosterManager));
        emit BoosterPurchased(msg.sender, 5 gwei, new uint256[](4));
        boosterManager.buyBooster{value: 5 gwei}();
    }
}