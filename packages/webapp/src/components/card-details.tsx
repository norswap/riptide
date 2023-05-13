import { useState } from "react";
import { CardProps } from "src/interfaces/card-props";

export const CardDetails = (card: CardProps) => {
 const [qty, setQty] = useState(card.quantity);
 const [price, setPrice] = useState(card.price);

  function handleSubmit(e) {
    // Prevent the browser from reloading the page
    e.preventDefault();

    const form = {
      id: card.id,
      qty, price
    };

    // You can pass formData as a fetch body directly:
    // fetch("/some-api", { method: form.method, body: formData });

    // Or you can work with it as a plain object:
   
    console.log(form);
  }

  const form = {
    id: card.id,
    quantity: card.quantity,
    price: card.price
  }

  return (
    <div className="">
      <h1>{card.name}</h1>
      <form method="post" onSubmit={handleSubmit}>
        <label>
          Quantity:
          <input
            type="number"
            value={qty}
            onChange={(e) => setQty(parseInt(e.target.value))}
          ></input>
        </label>

        <label>
          Price:
          <input
            type="number"
            value={price}
            onChange={(e) => setPrice(parseFloat(e.target.value))}
          ></input>
        </label>
        <button type="reset">Cancel</button>
        <button type="submit">Submit</button>
      </form>
    </div>
  );
};
