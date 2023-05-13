import { CardProps } from "src/interfaces/card-props";

export const CardDetails = (props: CardProps) => {
  return (
    <div className="">
      <h1>{props.name}</h1>
    </div>
  );
};
