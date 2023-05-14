// "event BoosterPurchased(address indexed buyer, uint256 price, uint256[] itemIDs)",
export default [
  {
    type: "event",
    name: "BoosterPurchased",
    inputs: [
      {
        indexed: true,
        name: "buyer",
        type: "address",
      },
      {
        indexed: false,
        name: "price",
        type: "uint256",
      },
      {
        indexed: false,
        name: "itemIDs",
        type: "uint256[]",
      },
    ],
  },
];
