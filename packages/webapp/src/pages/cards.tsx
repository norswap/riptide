import { cardsMock } from "./cards-mock";
import CardTable from "../components/CardTable";

export const Cards = () => {
  return (
    <div className="mx-auto max-w-4xl">
      <div className="flex flex-col py-8 gap-y-1">
        <h1 className="text-2xl">Cards</h1>
        <p className="text-lg text-white/60">Cards and their stats</p>
      </div>

      <CardTable cards={cardsMock} />

      {/*       {selected != null && (
        <div className="w-[800px] h-100 bg-teal-600">
          <CardDetails {...cardsMock[selected]}></CardDetails>
        </div>
      )} */}
    </div>
  );
};
