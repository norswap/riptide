// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

contract BoosterManager {

    struct ProbabilitySlot {
        uint16 typeID1;
        uint16 typeID2;
        uint8 probabilityFraction1;
        uint8 probabilityFraction2;
    }

    uint8 immutable public boosterSize;

    constructor(uint8 boosterSize_) {
        boosterSize = boosterSize_;
    }

    struct Probabilities {
        ProbabilitySlot[] array;
    }

    Probabilities private probabilities;

    function probabilitiesForRarityClassFromPrices(uint256[] calldata prices) external {
        uint256 average = 0;
        for (uint256 i = 0; i < prices.length; ++i)
            average += prices[i];
        average = average / prices.length;

        uint256[] memory weights = new uint256[](prices.length);
        for (uint256 i = 0; i < prices.length; ++i) {
            weights[i] = 1 + prices[i] / average;
        }

    }

    function postProbabilityArray(Probabilities calldata probabilities_) external {
        // TODO check only the attester can post this
        probabilities = probabilities_;
    }

    // Temporary randomness source
    function randomness() internal view returns(uint256) {
        return uint256(blockhash(block.number - 1));
    }

    // Returns a random item based on the booster manager's distribution parameters
    function pickItem() internal pure returns(uint256) {
        return 0;
    }

    // Returns a booster full of items (item IDs only, no NFT transferred)
    function getBooster() external view returns(uint8[] memory) {
        // TODO unique id?
        uint8[] memory booster = new uint16[](boosterSize);
        for (uint256 i = 0; i < boosterSize; ++i)
            booster[uint8(i)] = pickItem();
        return booster;
    }
}