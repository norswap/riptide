// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/access/Ownable.sol";

import "../BoostedCollection.sol";

enum Rarity {
    COMMON,
    UNUSUAL,
    RARE
}

struct CardTypeInfo {
    string name;
    string URL;
    uint16 ID;
    Rarity rarity;
}

contract CardCollection is ERC721, Ownable, BoostedCollection {

    uint256 private nextID = 0;

    // Cards types must be arrayed by rarity: first the common, then the unusual, then the rare.@author
    // The numCardsPerRarity mapping stores the number of cards of each rarity.

    CardTypeInfo[] public cardTypeInfos;
    mapping(uint256 cardID => uint16 cardTypeID) public cardTypes;
    uint8[3] public numCardsPerRarity;

    constructor(
        uint8[3] memory numCardsPerRarity_,
        CardTypeInfo[] memory cardTypeInfos_)
            ERC721("Cards", "CARD")
            Ownable() {
        numCardsPerRarity = numCardsPerRarity_;
        for (uint256 i = 0; i < cardTypeInfos_.length; ++i)
            cardTypeInfos.push(cardTypeInfos_[i]);
    }

    function mint(address to, uint8 rarityID, uint16 cardTypeID) external onlyOwner override returns(uint256) {
        // IMPORTANT: the cardTypeID in the parameter is different from the cardTypeID used
        // internally in the contract, we need to map one to the other first.
        uint16 contractCardTypeID = rarityID == 0
            ? cardTypeID
            : numCardsPerRarity[rarityID - 1] + cardTypeID;

        uint256 tokenID = nextID++;
        _safeMint(to, tokenID, "");
        cardTypes[tokenID] = contractCardTypeID;
        return tokenID;
    }

    function totalSupply() external view override returns(uint256) {
        return nextID;
    }

    function getCardTypeInfo(uint256 card) external view returns(CardTypeInfo memory) {
        return cardTypeInfos[cardTypes[card]];
    }
}