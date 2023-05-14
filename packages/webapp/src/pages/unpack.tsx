import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  useAccount,
  useContractEvent,
  useContractRead,
  useContractWrite,
  usePrepareContractWrite,
} from "wagmi";
import BoosterManagerAbi from "../constants/abis/BoosterManager.json";
import { BOOSTER_MANAGER } from "../constants/addresses";
import { parseAbi, parseEther } from "viem";

interface Card {
  id: number;
  name: string;
  image: string;
}

interface CardPackProps {
  cards: Card[];
}

const CardPack: React.FC<CardPackProps> = ({ cards }) => {
  const [isOpen, setIsOpen] = useState(false);

  const openPack = () => {
    setIsOpen(true);
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen">
      {!isOpen ? (
        <motion.button
          className="open-button"
          whileTap={{ scale: 0.9 }}
          onClick={openPack}
        >
          Open Pack
        </motion.button>
      ) : (
        <div className="flex space-x-4">
          {cards.map((card, i) => (
            <CardComponent delay={i * 0.1} key={card.id} card={card} />
          ))}
        </div>
      )}
    </div>
  );
};

interface CardComponentProps {
  delay: number;
  card: Card;
}

const CardComponent: React.FC<CardComponentProps> = ({ card, delay }) => {
  const [isFlipped, setIsFlipped] = useState(true);
  const variants = {
    flipped: { rotateY: 180 },
    unflipped: { rotateY: 0 },
  };

  const flip = () => {
    setIsFlipped(!isFlipped);
  };

  return (
    <motion.div
      initial={{
        y: Math.floor(Math.random() * 201) - 100,
        opacity: 0,
      }}
      animate={{ opacity: 1, y: 1 }}
      transition={{ duration: 0.2, delay: delay }}
    >
      <motion.div
        className={`relative w-32 h-48 backface-hidden rounded-lg overflow-hidden ${
          isFlipped ? "" : ""
        }`}
        initial="unflipped"
        animate={isFlipped ? "flipped" : "unflipped"}
        variants={variants}
        transition={{ duration: 0.3 }}
        whileTap={{ scale: 0.95 }}
        whileHover={{
          scale: 1.02,
          boxShadow: "0px 0px 12px 0px rgba(255,255,255,0.75)",
        }}
        onClick={flip}
      >
        {!isFlipped ? (
          <div className="absolute aspect-[2/3] inset-0 bg-blue-500 flex flex-row items-center justify-center text-2xl text-white font-bold">
            {/* Add your card back design here */}
            Card Back
          </div>
        ) : (
          <>
            <img
              className="w-full h-full bg-transparent"
              src={
                "data:image/jpeg;base64,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"
              }
              alt={card.name}
            />
          </>
        )}
      </motion.div>
    </motion.div>
  );
};

export default function Unpack() {
  const cardIds = [1, 2, 3, 4, 5, 6, 7];

  const { data, isError, isLoading } = useContractRead({
    address: BOOSTER_MANAGER,
    abi: BoosterManagerAbi,
    functionName: "boosterPrice",
  });

  // const unwatch = useContractEvent({
  //   address: BOOSTER_MANAGER,
  //   abi: BoosterManagerAbi,
  //   eventName: "BoosterPurchased",
  //   listener(log) {
  //   },
  // });

  useEffect(() => {
    console.log("data", data);
  }, [data]);

  const { config } = usePrepareContractWrite({
    address: BOOSTER_MANAGER,
    abi: BoosterManagerAbi,
    functionName: "buyBooster",
    args: [],
    value: 5000000000n,
  });

  const { write } = useContractWrite(config);

  const { address, isConnected } = useAccount();

  const buyBooster = () => {
    write();
  };

  return (
    <div>
      <button onClick={buyBooster}>Booster</button>
      {`Address: ${address}, Connected: ${isConnected}`}
      {/* <CardPack
        cards={[
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
          { id: 0, name: "YEet", image: " yee" },
        ]}
      /> */}
    </div>
  );
}
