import { useState } from "react";
import { cardsMock } from "./cards-mock";
import { CardDetails } from "../components/card-details";

export const Cards = () => {
  const [selected, setSelected] = useState<number>();

  return (
    <div className="flex flex-row">
      <div className="">
        <table className="table-auto text-left">
          <thead>
            <tr>
              <th>Name</th>
              <th>Qty</th>
              <th>Price</th>
            </tr>
          </thead>
          <tbody>
            {cardsMock.map((card, i) => (
              <tr
                className={`cursor-pointer hover:shadow-md shadow-cyan-500/50 ${
                  selected === i ? "bg-teal-600" : ""
                }`}
                onClick={() => setSelected(i)}
                key={i}
              >
                <td className="p-3 whitespace-nowrap">{card.name}</td>
                <td className="p-3">{card.quantity}</td>
                <td className="p-3">{card.price}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {selected != null && (
        <div className="w-[800px] h-100 bg-teal-600">
          <CardDetails {...cardsMock[selected]}></CardDetails>
        </div>
      )}
    </div>
  );
};
