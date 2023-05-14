import type { Address } from "wagmi";
import * as deployment_ from "contracts/out/deployment.json";

export interface Deployment {
  CardsCollection: Address;
  BoosterManager: Address;
  AssertionEngine: Address;
  AssertionManager: Address;
  Multicall3: Address;
}

export const deployment = deployment_ as unknown as Deployment;
