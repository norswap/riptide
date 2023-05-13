// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "../AssertionEngine.sol";

/**
 * Trivial implementation of the AssertionEngine interface that always accepts any price assertion
 * and allows for instant confirmation.
 */
contract DemoAssertionEngine is AssertionEngine {

    uint256 private nextID = 0;

    function assertPrices(uint256[][] calldata /* prices */) external override returns(uint256 assertionID) {
        return nextID++;
    }

    function confirmPrices(uint256 /* assertionID */) external pure override returns(bool) {
        return true;
    }

    function getConfirmationDelay() external pure override returns(uint256) {
        return 0;
    }
}