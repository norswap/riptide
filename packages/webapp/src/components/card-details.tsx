import { useState } from "react";
import { CardProps } from "src/interfaces/card-props";

export const CardDetails = (props: { card: CardProps, setSelected }) => {
const { card, setSelected } = props;
 const [price, setPrice] = useState(card.price);

  function handleSubmit(e) {
    // Prevent the browser from reloading the page
    e.preventDefault();

    const form = {
      id: card.id,
      price
    };

    // You can pass formData as a fetch body directly:
    // fetch("/some-api", { method: form.method, body: formData });
   
    console.log(form);
    setSelected(null)
  }

  return (
    <div className="">
      <h1>{card.name}</h1>
      <form className="flex flex-col" method="post" onSubmit={handleSubmit}>
        <label>
          Price: 
          <input
            type="number"
            value={price}
            onChange={(e) => setPrice(parseFloat(e.target.value))}
          ></input>
        </label>
        <div className="flex-row justify-center">
          <button
            type="reset"
            onClick={() => setSelected(null)}
          >
            Cancel
          </button>
          <button type="submit">Update price</button>
        </div>
      </form>
    </div>
  );
};
