// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.16;

import "uma-core/optimistic-oracle-v3/interfaces/OptimisticOracleV3Interface.sol";

// ***************************************
// *    Minimum Viable OOV3 Integration  *
// ***************************************

// This contract shows how to get up and running as quickly as possible with UMA's Optimistic Oracle V3.
// We make a simple data assertion about the real world and let the OOV3 arbitrate the outcome.

contract OOV3_GettingStarted {
    // Create an Optimistic Oracle V3 instance at the deployed address on Görli.
    OptimisticOracleV3Interface oov3 =
        OptimisticOracleV3Interface(0x9923D42eF695B5dd9911D05Ac944d4cAca3c4EAB);

    // Asserted claim. This is some truth statement about the world and can be verified by the network of disputers.
    bytes public assertedClaim = abi.encodePacked(
            "The mean price of all items of the common rarity is",
            // mean price of common items,
            " USDC at block timestamp:",
            // block.timestamp,
            ", knowing"
            // needed information
        );
    // TODO: change claim so that it take into account the timestamp & give cards informations

    // Each assertion has an associated assertionID that uniquly identifies the assertion. We will store this here.
    bytes32 public assertionId;

    // Assert the truth against the Optimistic Asserter. This uses the assertion with defaults method which defaults
    // all values, such as a) challenge window to 120 seconds (2 mins), b) identifier to ASSERT_TRUTH, c) bond currency
    //  to USDC and c) and default bond size to 0 (which means we dont need to worry about approvals in this example).
    function assertTruth() public {
        assertionId = oov3.assertTruthWithDefaults(assertedClaim, address(this));
    }

    // Settle the assertion, if it has not been disputed and it has passed the challenge window, and return the result.
    // result
    function settleAndGetAssertionResult() public returns (bool) {
        return oov3.settleAndGetAssertionResult(assertionId);
    }

    // Just return the assertion result. Can only be called once the assertion has been settled.
    function getAssertionResult() public view returns (bool) {
        return oov3.getAssertionResult(assertionId);
    }

    // Return the full assertion object contain all information associated with the assertion. Can be called any time.
    function getAssertion()
        public
        view
        returns (OptimisticOracleV3Interface.Assertion memory)
    {
        return oov3.getAssertion(assertionId);
    }
}