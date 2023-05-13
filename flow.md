# Flow

1. Get booster price (`BoosterManager.boosterPrice`)
2. Purchase booster (`BoosterManager.buyBooster`)
3. Parse logs to get the `BoosterPurchased` event emitted by `buyBooster`
   - Parse with `contract.interface.parseLog(data.logs[0])` (in `onSuccess` wagmi hook)
        - Get the `contract` via `const contract = useBoosterManager({ address: deployment.BoosterManager })`
   - Alternatively, can subscribe to the event as soon as the user logs in with their accounts
       ```javascript
       watchContractEvent({
           address: deployment.BoosterManager,
           abi: boosterManagerABI,
           eventName: "BoosterPurchased"},
         (args) => { /* ... */ })
       ```
4. Use the `itemIDs` in the event to get the NFT data from the `CardCollection` contract.
    - Use `CardCollection.getCardTypeInfo` to get the card info to display.