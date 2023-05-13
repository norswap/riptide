import { useMetaMask } from "../hooks/useMetaMask";

export const Home = () => {
  const { connectMetaMask, wallet } = useMetaMask();
  return (
    <div>
      <a href="/cards">
        <button>Navigate to cards</button>
      </a>
      {!wallet ? (
        <button onClick={connectMetaMask}>Conect</button>
      ) : (
        <>
          <div className="">{wallet.accounts[0]}</div>
        </>
      )}
    </div>
  );
};
