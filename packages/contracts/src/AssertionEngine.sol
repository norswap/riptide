// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

interface AssertionEngine {
    // Send a new price assertion, returning the assertion ID. If correct, we'll be able to call the
    // confirmPrices function with this ID at some point in the future (implementation-dependent)
    // and confirm that the prices were correct.
    function assertPrices(uint256[][] calldata prices) external returns (uint256 assertionID);

    // Returns true if it is known that the prices asserted by a preceding call of assertPrices were
    // correct. Returns false if either it is known that the prices were incorrect, or if it is not
    // yet possible to know, in which case `block.timestamp < assertionTimestamp +
    // getConfirmationDelay()`.
    function confirmPrices(uint256 assertionID) external view returns (bool);

    // Returns the delay between the assertion and the confirmation. Could be 0 if instant,
    // could also change over time (e.g. if a validity can be submitted).
    function getConfirmationDelay() external view returns (uint256);
}
