import { CardProps } from "src/interfaces/card-props";

export const Card = (props: CardProps) => {
  return (
    <div className="w-[120px] h-[200px]  bg-slate-200">
      {props.name}
    </div>
  );
};
