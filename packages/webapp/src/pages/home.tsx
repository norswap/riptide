import { useEffect } from "react";
// import { useMetaMask } from "../hooks/useMetaMask";
import { InjectedConnector } from "@wagmi/core";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

export const Home = () => {
  const { isConnected, address } = useAccount();

  return (
    <div className="flex flex-col items-center justify-center h-screen space-y-3">
      <div className="flex-row space-x-3">
        <a href="/cards">
          <button>Navigate to cards</button>
        </a>
        <a href="/unpack">
          <button>Unpack</button>
        </a>
      </div>
      <h1></h1>
      {!isConnected ? (
        <ConnectButton />
      ) : (
        <>
          <div className="text-white">{address}</div>
        </>
      )}
    </div>
  );
};
