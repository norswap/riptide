// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "./AssertionEngine.sol";
import "./BoosterManager.sol";

import "openzeppelin/access/Ownable.sol";

/**
 * This contract manages the lifecycle of price claims which are necessary to update the weights
 * (probabilities) of item dropping in booster packs.
 */
contract AssertionManager is Ownable {

    // The booster manager that we manage price assertions for.
    BoosterManager public boosterManager;

    // Engine that will be used to check the assertion.
    AssertionEngine public engine;

    // Currently claimed item prices.
    uint256[][] public prices;

    // Assertion ID for the currently claimed prices.
    uint256 public assertionID;

    // Timestamp for the last update.
    uint256 public lastUpdate;

    // Time to wait before updating the prices after the last update.
    uint256 public updateInterval;

    constructor(BoosterManager boosterManager_, AssertionEngine engine_, uint256 updateInterval_) Ownable() {
        boosterManager = boosterManager_;
        engine = engine_;
        updateInterval = updateInterval_;
    }

    function assertPrices(uint256[][] calldata prices_) external {
        // TODO permission control: only owner or anybody after a delay

        if (block.timestamp < lastUpdate + updateInterval)
            revert("BoosterManager: too early to update prices");
        lastUpdate = block.timestamp;

        boosterManager.validatePricesShape(prices_);

        if (prices.length != 0)
                revert("BoosterManager: prices array should be empty, call resetAssertion first");

        // copy prices_ to prices
        for (uint256 i = 0; i < prices_.length; ++i) {
            prices.push();
            for (uint256 j = 0; j < prices_[i].length; ++j)
                prices[i].push(prices_[i][j]);
        }

        assertionID = engine.assertPrices(prices_);

        // TODO check this doesn't happen, but let's be safe for now
        if (assertionID == 0)
            revert("BoosterManager: zero assertion ID");
    }

    function confirmPrices() external {
        if (assertionID == 0)
            revert("AssertionManager: no assertion in progress");
        if (block.timestamp < lastUpdate + engine.getConfirmationDelay())
            revert("AssertionManager: too early to confirm prices");
        if (!engine.confirmPrices(assertionID))
            revert("AssertionManager: assertion not confirmed and should be reset");

        boosterManager.setWeightsFromPrices(prices);

        // reset state (but not timestamp!)
        delete prices;
        assertionID = 0;
    }

    // Whether the current assertion (if any) is known to be correct, false if there is no assertion
    // in progress, if it is known to be incorrect, or if it is not yet possible to know.
    function assertionConfirmed() view public returns(bool) {
        return assertionID != 0 && engine.confirmPrices(assertionID);
    }

    // Resets the assertion state if an assertion is in progress but its delay has passed and it is
    // still incomfirmed. Reverts if the assertion state cannot be reset.
    function resetAssertion() external onlyOwner {
        if (block.timestamp < lastUpdate + engine.getConfirmationDelay())
            revert("AssertionManager: too early to reset assertion");
        if (assertionID == 0)
            revert("AssertionManager: no assertion in progress");
        if (engine.confirmPrices(assertionID))
            revert("AssertionManager: assertion is confirmed");

        lastUpdate = 0;
        assertionID = 0;
        delete prices;
    }

//    function assertWeightsFromPrices(uint256[][] calldata prices_) external onlyOwner {
//        // TODO UMA integration
//        // TODO allow other people to call this, after a delay
//        if (prices.length != rarityClasses.length)
//            revert("BoosterManager: invalid number of rarity classes");
//        WeightSlot[][] memory generatedWeights = weightsFromPrices(prices).array;
//        for (uint256 i = 0; i < prices.length; ++i) {
//            if (prices[i].length != rarityClasses[i].totalItems)
//                revert("BoosterManager: invalid number of items for rarity class");
//            for (uint256 j = 0; j < prices[i].length; ++j)
//                weights.array[i][j] = generatedWeights[i][j];
//        }
//    }

//    function assertWeights(BoosterManager.Weights calldata weights_) public onlyOwner {
//        // TODO UMA integration
//        // TODO allow other people to call this, after a delay
//        if (weights.array.length != rarityClasses.length)
//            revert("BoosterManager: invalid number of rarity classes");
//        weights = weights_;
//    }
}