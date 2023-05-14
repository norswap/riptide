import { useEffect } from "react";
// import { useMetaMask } from "../hooks/useMetaMask";
import { InjectedConnector } from "@wagmi/core";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

export const Home = () => {
  const { isConnected, address } = useAccount();

  return (
    <div>
      <a href="/cards">
        <button>Navigate to cards</button>
      </a>
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
