// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.19;

import "openzeppelin/access/Ownable.sol";
import { UD60x18, ud, log10, ceil, convert } from "prb-math/UD60x18.sol";
import "forge-std/console2.sol";

import "./AssertionManager.sol";
import "./BoostedCollection.sol";

/**
 * The BoosterManager contract forms the core of RIPTIDE, it is responsible for generating booster
 * packs according to the parameters it is configured with and the item prices, as well as pricing
 * boosters based on the item supply.
 *
 * The NFTs minted by this contract are called "items". The interface between this contract and
 * a NFT collection (or multiple NFT collections, this is completely abstracted away) is done with
 * the BoostedCollection interface.
 *
 * Each item has an uint256 `itemID` which is the usual ERC721 token ID.
 *
 * Each item has a "rarity class". The BoosterManager contract is configured with a list of rarity
 * classes. The uint8 `rarityID` is an index into the `rarityClasses` storage array.
 *
 * Each item has a RARITY-SPECIFIC "type", which is what the BoosterManager generates when
 * constructs a booster. The uint16 `typeID` designates the type of item to be minted. These IDs are
 * sequential in the 0-N range, where N is the number of items in the rarity class (configured when
 * creating the booster manager).
 *
 * Both the `rarityID` and the `typeID` are passed to the BoostedCollection.mint function in order to
 * mint the proper item. The BoostedCollection implementation can map these IDs to its own internal
 * system.
 */
contract BoosterManager is Ownable {

    // =============================================================================================
    // CONFIGURATION

    // Emitted after a booster is purchased, giving the ID of the acquired NFTs.
    event BoosterPurchased(address indexed buyer, uint256 price, uint256[] itemIDs);

    // Number of items in each booster.
    uint8 immutable public boosterSize;

    // The total number of card types, summing accross all rarity classes.
    uint16 immutable public totalNumCardTypes;

    // Boosters will stay at the initial price until the card supply reaches this number.
    uint256 immutable public targetBaseSupply;

    // Initial price (18 decimals) of a booster.
    uint256 immutable public initialBoosterPrice;

    // An item will have weight (1 + logMultiplier * log10(price / averagePrice)), where price is
    // its own price, and averagePrice is the average price of all items in the rarity classes.
    UD60x18 immutable public logMultiplier;

    // Current price (18 decimals) of a booster.
    uint256 public currentBoosterPrice;

    // The contract that mints NFTs contained in boosters.
    BoostedCollection public boostedConnection;

    // The contract that manages price assertions and is allowed to update the weights of items
    // based on these prices.
    AssertionManager public assertionManager;

    struct RarityClass {
        // Number of items in the rarity class.
        uint16 totalItems;
        // Number of items of this rarity class in each booster.
        uint8 itemsPerBooster;
        // ID of the rarity class. Not used for anything atm.
        uint8 ID;
    }

    // Rarity class configuration: each rarity class is identified by its ID into this array.
    RarityClass[] public rarityClasses;

    constructor(
        BoostedCollection boostedCollection_,
        UD60x18 logMultiplier_,
        uint256 targetBaseSupply_,
        uint256 initialBoosterPrice_,
        RarityClass[] memory rarityClasses_)
            Ownable() {
        boostedConnection = boostedCollection_;
        logMultiplier = logMultiplier_;
        targetBaseSupply = targetBaseSupply_;
        initialBoosterPrice = initialBoosterPrice_;
        uint8 boosterSize_ = 0;
        uint16 totalNumCardTypes_ = 0;
        for (uint256 i = 0; i < rarityClasses_.length; ++i) {
            boosterSize_ += rarityClasses_[i].itemsPerBooster;
            totalNumCardTypes_ += rarityClasses_[i].totalItems;
            rarityClasses.push(rarityClasses_[i]);
        }
        if (totalNumCardTypes_ == 0)
            revert("BoosterManager: totalNumCardTypes cannot be zero");
        boosterSize = boosterSize_;
        totalNumCardTypes = totalNumCardTypes_;
    }

    function setAssertionManager(AssertionManager assertionManager_) external onlyOwner {
        if (address(assertionManager) != address(0))
            revert("BoosterManager: assertionManager already set");
        assertionManager = assertionManager_;
    }

    // =============================================================================================
    // RANDOMNESS-RELATED FIELDS

    // Last block number on which a booster was purchased.
    uint256 private blockNumber = 0;

    // Sequence number relative to blockNumber.
    uint256 private sequenceNumberInBlock = 0;

    // =============================================================================================
    // WEIGHTS-RELATED FIELDS

    // The data structure used to decide which items are in a booster, based on weights computed
    // from item prices. Each slot represent one "unit" of weight, which can further be split
    // between two different item types. More than two item types cannot be in the same slot because
    // the "weight" for each item type is at least one.
    //
    // Each unit of weight can furthermore be split into 255 sub-units, the sub-units determining
    // the probability of the first item type being chosen against the second item type depending on
    // the specific randomness.
    struct WeightSlot {
        uint16 typeID1;
        uint16 typeID2;
        // 0-255 representing the probability of typeID1 being chosen against typeID2 if the
        // randomness lands within this slot.
        uint8 probabilitySplit;
    }

    struct Weights {
        WeightSlot[][] array;
    }

    Weights private weights;

    // =============================================================================================
    // BOOSTER GENERATION & PURCHASE

    // Current booster price.
    function boosterPrice() public view returns(uint256) {
        if (boostedConnection.totalSupply() < targetBaseSupply)
            return initialBoosterPrice;
        else {
            // NOTE: this could be tweaked or made configurable
            uint256 supplyDiff = boostedConnection.totalSupply() - targetBaseSupply;
            // e.g. if target is 1000, getting to 2000 total supply, would take price to
            // `initial + 10^6 / (3*10^5) = inital + 3.3`, at 3000 it would be `initial + 13.3`
            return initialBoosterPrice + supplyDiff * supplyDiff / 300_000;
        }

    }

    // Purchase a booster at the current price.
    function buyBooster() external payable {
        // TODO handle slippage
        if (msg.value < boosterPrice())
            revert("BoosterManager: insufficient payment");

        // TODO move sequencer number handling up here
        uint256 i = 0;
        uint256[] memory items = new uint256[](boosterSize);
        for (uint8 rarityID = 0; rarityID < rarityClasses.length; ++rarityID) {
            for (uint256 j = 0; j < rarityClasses[rarityID].itemsPerBooster; ++j) {
                console2.log(rarityID, j, i);
                console2.log(pickItem(rarityID));
                console2.log("done");
                items[i++] = boostedConnection.mint(msg.sender, rarityID, pickItem(rarityID));
            }
        }

        emit BoosterPurchased(msg.sender, msg.value, items);
    }

    // Temporary (biasable!) randomness source
    function randomness() internal view returns(uint256) {
        return uint256(blockhash(block.number - 1));
    }

    // Returns a random item of the requested rarity based on the booster manager's parameters.
    function pickItem(uint8 rarityID) internal returns(uint16) {
        uint256 seqNum;
        if (blockNumber != block.number) {
            blockNumber = block.number;
            seqNum = sequenceNumberInBlock = 0;
        } else {
            seqNum = ++sequenceNumberInBlock;
        }
        uint256 seed = randomness();
        uint16 numItems = rarityClasses[rarityID].totalItems;
        uint256 random = uint256(keccak256(abi.encodePacked(seed, seqNum))) % (numItems * 256);
        console2.log("random", random, "block", block.number);
        // TODO set weights
        WeightSlot memory slot = weights.array[rarityID][random / 256];
        return random % 256 <= slot.probabilitySplit ? slot.typeID1 : slot.typeID2;
    }

    // =============================================================================================
    // DEFINING THE WEIGHTS

    function weightsForRarityFromPrices(uint256[] calldata prices)
            internal view returns(WeightSlot[] memory) {

        uint256 average = 0;
        for (uint256 i = 0; i < prices.length; ++i)
            average += prices[i];
        average = average / prices.length;

        UD60x18 ONE = ud(1);
        UD60x18 avg = ud(average);
        UD60x18[] memory decimalWeights = new UD60x18[](prices.length);
        UD60x18 totalWeight = ud(0);
        for (uint256 i = 0; i < prices.length; ++i) {
            decimalWeights[i] = ONE + logMultiplier * log10(ud(prices[i]) / avg);
            totalWeight = totalWeight + decimalWeights[i];
        }

        WeightSlot[] memory rarityWeights = new WeightSlot[](convert(ceil(totalWeight)));
        uint16 lastTypeID = 0;
        // TODO check conversion doesn't overflow
        uint16 remainingWeight = uint16(convert(decimalWeights[lastTypeID] * ud(256)));
        for (uint256 i = 0; i < rarityWeights.length; ++i) {
            rarityWeights[i].typeID1 = lastTypeID;
            if (remainingWeight >= 256) {
                remainingWeight -= 256;
                rarityWeights[i].probabilitySplit = 255;
            } else {
                rarityWeights[i].probabilitySplit = uint8(remainingWeight - 1); // because it includes 0
                if (lastTypeID == decimalWeights.length) break;
                rarityWeights[i].typeID2 = ++lastTypeID;
                uint8 remainingProbabilityInSlot = 255 - rarityWeights[i].probabilitySplit;
                remainingWeight = uint16(convert(decimalWeights[lastTypeID] * ud(256))) - remainingProbabilityInSlot;
            }
        }

        return rarityWeights;
    }

    function weightsFromPrices(uint256[][] calldata prices) public view returns(Weights memory) {
        if (prices.length != rarityClasses.length)
            revert("BoosterManager: invalid number of rarity classes");

        Weights memory generatedWeights = Weights(new WeightSlot[][](prices.length));
        for (uint256 rarityID = 0; rarityID < prices.length; ++rarityID) {
            if (prices[rarityID].length != rarityClasses[rarityID].totalItems)
                revert("BoosterManager: invalid number of items for rarity class");
            console2.log("weights for rarity", rarityID);
            generatedWeights.array[rarityID] = weightsForRarityFromPrices(prices[rarityID]);
        }

        return generatedWeights;
    }

    // Called by the assertion manager to validate that the number of prices is correct.
    function validatePricesShape(uint256[][] calldata prices) external view {
        if (prices.length != rarityClasses.length)
            revert("BoosterManager: invalid number of rarity classes");
        for (uint256 rarityID = 0; rarityID < prices.length; ++rarityID)
            if (prices[rarityID].length != rarityClasses[rarityID].totalItems)
                revert("BoosterManager: invalid number of items for rarity class");
    }

    // Called by the assertion manager to set the weights based on the prices.
    function setWeightsFromPrices(uint256[][] calldata prices) external {
        if (msg.sender != address(assertionManager))
            revert("BoosterManager: only assertion manager can set weights");

        WeightSlot[][] memory generatedWeights = weightsFromPrices(prices).array;
        for (uint256 i = 0; i < prices.length; ++i)
            for (uint256 j = 0; j < prices[i].length; ++j)
                weights.array[i][j] = generatedWeights[i][j];
    }

    // =============================================================================================
}