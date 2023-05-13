import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";
import "./index.css";
import { MetaMaskContextProvider } from "./hooks/useMetaMask.tsx";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <MetaMaskContextProvider>
      <App />
    </MetaMaskContextProvider>
  </React.StrictMode>
);
