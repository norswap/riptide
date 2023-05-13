// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

/**
 * To implement by NFT collections (or adaptors in front or one or multiple underlying NFT
 * collections) that want to use the booster distribution.
 */
interface BoostedCollection {
    /**
     * Instructs to mint a card of the given type to the given address, returning the resulting item
     * (NFT) ID.
     */
    function mint(address to, uint8 rarityID, uint16 cardTypeID) external returns(uint256);

    /**
     * Returns the total number of items (NFTs) minted by this contract (not necessarily only items
     * minted via the booster mechanism).
     */
    function totalSupply() external view returns(uint256);
}