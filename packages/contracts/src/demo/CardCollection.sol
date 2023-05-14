// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/access/Ownable.sol";

import "../BoostedCollection.sol";
import "../BoosterManager.sol";

enum Rarity {
    COMMON,
    UNUSUAL,
    RARE
}

struct CardTypeInfo {
    string name;
    string URL;
    uint256 supply;
    uint16 ID;
    Rarity rarity;
}

contract CardCollection is ERC721, Ownable, BoostedCollection {

    uint256 private nextID = 0;

    // Cards types must be arrayed by rarity: first the common, then the unusual, then the rare.@author
    // The numCardsPerRarity mapping stores the number of cards of each rarity.

    CardTypeInfo[] public cardTypeInfos;
    mapping(uint256 cardID => uint16 cardTypeID) public cardTypes;
    uint16[3] public firstCardOfRarity;
    BoosterManager public boosterManager;

    constructor(CardTypeInfo[] memory cardTypeInfos_)
            ERC721("Cards", "CARD")
            Ownable() {

        uint8 currentRarity = 0;
        uint16 cumulativeCards = 0;
        firstCardOfRarity[0] = 0;
        for (uint256 i = 0; i < cardTypeInfos_.length; ++i) {
            if (cardTypeInfos_[i].rarity != Rarity(currentRarity))
                firstCardOfRarity[++currentRarity] = cumulativeCards;
            cardTypeInfos.push(cardTypeInfos_[i]);
            ++cumulativeCards;
        }
    }

    function setBoosterManager(BoosterManager boosterManager_) external onlyOwner {
        boosterManager = boosterManager_;
    }

    function getCardTypeInfos() external view returns(CardTypeInfo[] memory) {
        return cardTypeInfos;
    }

    function mint(address to, uint8 rarityID, uint16 cardTypeID) external override returns(uint256) {
        if (msg.sender != address(boosterManager))
            revert("CardCollection: Only the booster manager can mint cards in this way");

        // IMPORTANT: the cardTypeID in the parameter is different from the cardTypeID used
        // internally in the contract, we need to map one to the other first.
        uint16 contractCardTypeID = rarityID == 0
            ? cardTypeID
            : firstCardOfRarity[rarityID] + cardTypeID;

        uint256 tokenID = nextID++;
        _safeMint(to, tokenID, "");
        cardTypes[tokenID] = contractCardTypeID;
        cardTypeInfos[contractCardTypeID].supply++;
        return tokenID;
    }

    function totalSupply() external view override returns(uint256) {
        return nextID;
    }

    function getCardTypeInfo(uint256 card) external view returns(CardTypeInfo memory) {
        return cardTypeInfos[cardTypes[card]];
    }
}