import { CardProps } from "src/interfaces/card-props";
import { Tilt } from "react-tilt";
import { motion } from "framer-motion";

const options = {
  max: 10,
  scale: 1,
};

const cardVariants = {
  hover: {
    scale: 1.02,
  },
};

export const Card = ({ name }: CardProps) => (
  <motion.div className="rounded-md" whileHover="hover" variants={cardVariants}>
    <Tilt
      style={{
        transformStyle: "preserve-3d",
      }}
      options={options}
      className={`p-4 aspect-[2.5/3.5] border rounded-lg border-gray-800 hover:shadow-xl hover:border-gray-600 hover:bg-white/5  bg-cover bg-center bg-no-repeat before:blur-sm before:bg-inherit before:brightness-50`}
    >
      {name}
    </Tilt>
  </motion.div>
);
