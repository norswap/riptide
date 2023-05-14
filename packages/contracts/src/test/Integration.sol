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

    address private constant Alice = 0x00000000000000000000000000000000DeaDBeef;

    CardTypeInfo[] private cardTypeInfos;
    uint256[][] private prices;

    CardCollection private cardCollection;
    BoosterManager private boosterManager;
    DemoAssertionEngine private engine;
    AssertionManager private assertionManager;

    function setUp() public {
        // name, URL, supply, ID, rarity
        cardTypeInfos.push(CardTypeInfo("Common 1", "pic://common1.png", 0, 0, Rarity.COMMON));
        cardTypeInfos.push(CardTypeInfo("Common 2", "pic://common2.png", 0, 1, Rarity.COMMON));
        cardTypeInfos.push(CardTypeInfo("Unusual 1", "pic://unusual1.png", 0, 2, Rarity.UNUSUAL));
        cardTypeInfos.push(CardTypeInfo("Unusual 2", "pic://unusual2.png", 0, 3, Rarity.UNUSUAL));
        cardTypeInfos.push(CardTypeInfo("Rare 1", "pic://rare1.png", 0, 4, Rarity.RARE));
        cardTypeInfos.push(CardTypeInfo("Rare 2", "pic://rare2.png", 0, 5, Rarity.RARE));

        BoosterManager.RarityClass[] memory rarityClasses = new BoosterManager.RarityClass[](3);
        // total items, items per booster, rarity ID
        rarityClasses[0] = BoosterManager.RarityClass(2, 4, 0);
        rarityClasses[1] = BoosterManager.RarityClass(2, 2, 1);
        rarityClasses[2] = BoosterManager.RarityClass(2, 1, 2);

        cardCollection = new CardCollection(cardTypeInfos);

        boosterManager = new BoosterManager(
            BoostedCollection(cardCollection),
            ud(2 ether), // log multiplier
            20, // target base supply
            5 gwei, // initial booster price
            rarityClasses);
        cardCollection.setBoosterManager(boosterManager);

        engine = new DemoAssertionEngine();

        assertionManager = new AssertionManager(boosterManager, engine, 0);
        boosterManager.setAssertionManager(assertionManager);

        prices.push();
        prices[0].push(5 gwei);
        prices[0].push(5 gwei);
        prices.push();
        prices[1].push(10 gwei);
        prices[1].push(10 gwei);
        prices.push();
        prices[2].push(20 gwei);
        prices[2].push(20 gwei);
        assertionManager.assertPrices(prices);
        assertionManager.confirmPrices();
    }

    // Same signature as BoosterManager.BoosterPurchased.
    event BoosterPurchased(address indexed buyer, uint256 price, uint256[] itemIDs);
    // sig: BoosterPurchased(address,uint256,uint256[]);

    function testIntegration() public {
        assertEq(boosterManager.boosterPrice(), 5 gwei);
        vm.deal(msg.sender, 5 ether);

        startHoax(Alice, 5 ether);
        vm.expectEmit(true, true, false, true, address(boosterManager));
        uint256[] memory itemIDs = new uint256[](7);
        for (uint256 i = 0; i < itemIDs.length; i++)
            itemIDs[i] = i;
        emit BoosterPurchased(Alice, 5 gwei, itemIDs);
        boosterManager.buyBooster{value: 5 gwei}();
        assertEq(Alice.balance, 5 ether - 5 gwei);

        boosterManager.buyBooster{value: 5 gwei}();
        boosterManager.buyBooster{value: 5 gwei}();
        assertTrue(boosterManager.boosterPrice() > 5 gwei);
        boosterManager.buyBooster{value: boosterManager.boosterPrice()}();
        boosterManager.buyBooster{value: boosterManager.boosterPrice()}();

        prices[0][0] = 1 ether;
        prices[1][0] = 2 ether;
        prices[2][0] = 8 ether;
        assertionManager.assertPrices(prices);
        assertionManager.confirmPrices();

        vm.recordLogs();
        boosterManager.buyBooster{value: boosterManager.boosterPrice()}();
        Vm.Log[] memory logs = vm.getRecordedLogs();
        Vm.Log memory last = logs[logs.length - 1];
        assertEq(last.topics[0], keccak256("BoosterPurchased(address,uint256,uint256[])"));
        (, uint256[] memory biasedItemIDs) = abi.decode(last.data, (uint256, uint256[]));

        biasedItemIDs[0] = biasedItemIDs[0]; // silence warnings

        // TODO remove constants - parameterize

        // TODO this works, but because there are only two cards, the massively more expensive card
        //  is only twice the average, making the scaling effect less obvious

//        for (uint256 i = 0; i < 4; i++) {
//            // We set the price of the first item in each rarity class to be vastly superior to the
//            // other one, so they should always drop.
//            assertEq(cardCollection.getCardTypeInfo(biasedItemIDs[i]).name, "Common 1");
//        }
//        for (uint256 i = 4; i < 6; i++) {
//            // We set the price of the first item in each rarity class to be vastly superior to the
//            // other one, so they should always drop.
//            assertEq(cardCollection.getCardTypeInfo(biasedItemIDs[i]).name, "Unusual 1");
//        }
//        for (uint256 i = 6; i < 7; i++) {
//            // We set the price of the first item in each rarity class to be vastly superior to the
//            // other one, so they should always drop.
//            assertEq(cardCollection.getCardTypeInfo(biasedItemIDs[i]).name, "Rare 1");
//        }
    }
}