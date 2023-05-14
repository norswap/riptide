import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  useAccount,
  useContractEvent,
  useContractRead,
  useContractWrite,
  usePrepareContractWrite,
  useContractReads,
} from "wagmi";
import BoosterManagerAbi from "../constants/abis/BoosterManager.json";
import CardCollectionAbi from "../constants/abis/CardCollection.json";
import { BOOSTER_MANAGER, CARD_COLLECTION } from "../constants/addresses";
import { CardTypeInfo } from "types";
import CardBack from "../assets/images/cardback.png";
import { Tilt } from "react-tilt";

interface CardPackProps {
  cards: CardTypeInfo[];
}

const cardMap = {
  polygon: {
    image: "img/polygon.jpg",
  },
  "gnosis-chain": {
    image: "img/gnosis-chain.jpg",
  },
  "1inch-network": {
    image: "img/1inch-network.jpg",
  },
  worldcoin: {
    image: "img/worldcoin.jpg",
  },
  optimism: {
    image: "img/optimism.jpg",
  },
  "uniswap-foundation": {
    image: "img/uniswap-foundation.jpg",
  },
  "lens-protocol": {
    image: "img/lens-protocol.jpg",
  },
  // "filecoin-virtual-machine-fvm": {
  //   image: "img/filecoin-virtual-machine-fvm.jpg",
  // },
  "metamask-linea": {
    image: "img/metamask-linea.jpg",
  },
  "aave-grants-dao": {
    image: "img/aave-grants-dao.jpg",
  },
  uma: {
    image: "img/uma.jpg",
  },
  // cartesi: {
  //   image: "img/cartesi.jpg",
  // },
  // airstack: {
  //   image: "img/airstack.jpg",
  // },
  // safe: {
  //   image: "img/safe.jpg",
  // },
  "ethereum-foundation": {
    image: "img/ethereum-foundation.jpg",
  },
  zkbob: {
    image: "img/zkbob.jpg",
  },
  "apecoin-dao": {
    image: "img/apecoin-dao.jpg",
  },
  // "the-graph": {
  //   image: "img/the-graph.jpg",
  // },
  // fuel: {
  //   image: "img/fuel.jpg",
  // },
  // sismo: {
  //   image: "img/sismo.jpg",
  // },
  // scroll: {
  //   image: "img/scroll.jpg",
  // },
  // "neon-foundation": {
  //   image: "img/neon-foundation.jpg",
  // },
  // "nouns-dao": {
  //   image: "img/nouns-dao.jpg",
  // },
  // chainlink: {
  //   image: "img/chainlink.jpg",
  // },
  // mantle: {
  //   image: "img/mantle.jpg",
  // },
};
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
  card: CardTypeInfo;
}

const boxShadowColorByRarity = {
  0: "rgba(232, 232, 232, 0.8)",
  1: "rgba(125, 249, 255, 0.8)",
  2: "rgba(255, 223, 0, 0.8)",
};

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
    <div className="flex flex-col items-center gap-y-4">
      <motion.div
        initial={{
          y: Math.floor(Math.random() * 201) - 100,
          opacity: 0,
        }}
        animate={{ opacity: 1, y: 1 }}
        transition={{ duration: 0.2, delay: delay }}
      >
        <Tilt
          options={{
            max: 20,
            scale: 1,
          }}
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
              scale: 1.01,
              boxShadow: `0px 0px 20px 0px ${
                boxShadowColorByRarity[card.rarity]
              }`,
            }}
            onClick={flip}
          >
            {!isFlipped ? (
              <div
                style={{
                  backgroundImage: `url(${cardMap[card.name].image})`,
                  backgroundSize: "cover",
                  backgroundPosition: "center",
                }}
                className="absolute aspect-[2/3] inset-0 bg-black  flex flex-row items-center justify-center text-2xl text-white font-bold"
              ></div>
            ) : (
              <>
                <img
                  className="w-full h-full bg-transparent"
                  src={CardBack}
                  alt={card.name}
                />
              </>
            )}
          </motion.div>
        </Tilt>
      </motion.div>
    </div>
  );
};

export default function Unpack() {
  const [itemIDs, setItemIDs] = useState<number[]>([]);

  const { data: cardInfoData, fetchStatus } = useContractReads({
    //@ts-ignore
    contracts: itemIDs.map((id) => ({
      address: CARD_COLLECTION,
      abi: CardCollectionAbi,
      functionName: "getCardTypeInfo",
      args: [id],
    })),
  });

  useEffect(() => {
    console.log("itemIDs", itemIDs);
    console.log("cardInfoData", cardInfoData);
  }, [cardInfoData, fetchStatus]);

  const { data, isError, isLoading } = useContractRead({
    address: BOOSTER_MANAGER,
    abi: BoosterManagerAbi,
    functionName: "boosterPrice",
  });

  const unwatch = useContractEvent({
    address: BOOSTER_MANAGER,
    abi: BoosterManagerAbi,
    eventName: "BoosterPurchased",
    listener(logs) {
      for (let i = 0; i < logs.length; i++) {
        const log = logs[i];
        //@ts-ignore
        const { buyer, itemIDs } = log.args;
        if (buyer == address) {
          console.log("booster purchased");
          setItemIDs(itemIDs);
        }
      }
    },
  });

  useEffect(() => {
    console.log("data", data);
  }, [data]);

  const { config } = usePrepareContractWrite({
    //@ts-ignore
    address: BOOSTER_MANAGER,
    //@ts-ignore
    abi: BoosterManagerAbi,
    //@ts-ignore
    functionName: "buyBooster",
    args: [],
    //@ts-ignore
    value: 5841000000n,
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
      {cardInfoData && cardInfoData.length > 0 && (
        <CardPack
          cards={
            cardInfoData
              .map((cardInfo) => cardInfo.result)
              .filter(Boolean) as any
          }
        />
      )}
    </div>
  );
}
