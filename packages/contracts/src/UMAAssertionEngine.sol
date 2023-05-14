// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "./AssertionEngine.sol";
import "./DataAsserter.sol";

abstract contract UMAAssertionEngine is AssertionEngine {

    DataAsserter public dataAsserter;

    // Send a new price assertion, returning the assertion ID. If correct, we'll be able to call the
    // confirmPrices function with this ID at some point in the future (implementation-dependent)
    // and confirm that the prices were correct.
    function assertPrices(uint256[][] calldata prices) external override returns (uint256 assertionID){
        return uint256(dataAsserter.assertDataFor(
            bytes32(abi.encode(prices)), // identifier for the data: a hash of the price array
            bytes32(abi.encode(prices)), // data: an array[rariryLevel][itemID] = weight (probability of item appearing in a booster)
            // cannot be converted to bytes 32 -> hash of the array ? or do the average ?
            msg.sender));
    }

    // Returns true if it is known that the prices asserted by a precedg call of assertPrices were
    // correct. Returns false if either i²t is known that the prices were incorrect, or if it is not
    // yet possible to know, in which case `block.timestamp < assertionTimestamp +
    // getConfirmationDelay()`.
    function confirmPrices(uint256 assertionID) external override view returns (bool confirmation) {
        (confirmation, ) = dataAsserter.getData(bytes32(assertionID));
    }

    // Returns the delay between the assertion and the confirmation. Could be 0 if instant,
    // could also change over time (e.g. if a validity can be submitted).
    function getConfirmationDelay() external pure override returns (uint256) {
        return 2 hours;
    }
}