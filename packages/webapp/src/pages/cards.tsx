import { useState } from "react";
import { cardsMock } from "./cards-mock";

export const Cards = () => {
  const [selected, setSelected] = useState<number>();

  return (
    <>
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
            <tr className="m-3" onClick={() => setSelected(i)}>
              <td>{card.name}</td>
              <td>{card.quantity}</td>
              <td>{card.price}</td>
            </tr>
          ))}
        </tbody>
      </table>

      {selected && <div className="col-span-7 h-full back-black"></div>}
    </>
  );
};
