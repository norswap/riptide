import { CARD_COLLECTION } from "../constants/addresses";
import CardTable from "../components/CardTable";
import { useContractRead } from "wagmi";
import { useEffect } from "react";
import CardCollectionAbi from "../constants/abis/CardCollection.json";

export const Cards = () => {
  const { data } = useContractRead({
    address: CARD_COLLECTION,
    abi: CardCollectionAbi,
    functionName: "getCardTypeInfos",
  });

  useEffect(() => {
    console.log("data", data);
  }, [data]);

  return (
    <div className="mx-auto h-full max-w-4xl">
      <div className="flex flex-col py-8 gap-y-1 text-white">
        <h1 className="text-2xl">Cards</h1>
        <p className="text-lg text-white/60">Cards and their stats</p>
      </div>

      {data && <CardTable cards={data as any} />}

      {/*       {selected != null && (
        <div className="w-[800px] h-100 bg-teal-600">
          <CardDetails {...cardsMock[selected]}></CardDetails>
        </div>
      )} */}
    </div>
  );
};
