// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

interface BoosterMinter {
    // Instructs to mint a card of the given type to the given address, returning the resulting item
    // (NFT) ID.
    function mint(address to, uint8 rarityID, uint16 cardTypeID) external returns(uint256);
}