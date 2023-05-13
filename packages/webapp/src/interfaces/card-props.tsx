export interface CardProps {
  id: string;
  name: string;
  quantity: number;
  price: number;
  description: string;
  card_type: "monster" | "spell" | "trap";
  attack_points: number;
  defense_points: number;
}
