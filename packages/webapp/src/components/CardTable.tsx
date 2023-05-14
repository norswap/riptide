import { Fragment, useState } from "react";
import { Dialog, Transition } from "@headlessui/react";
import { CardDetails } from "./card-details";
import { CardTypeInfo } from "src/types";

interface CardTableProps {
  cards?: CardTypeInfo[];
}

const rarityMappings = {
  0: "Common",
  1: "Unusual",
  2: "Rare",
};

const priceMappings = {
  0: 5,
  1: 10,
  2: 20,
};

const nameMappings = {
  polygon: "Polydrake",
  "gnosis-chain": "Chainicorn",
  "1inch-network": "Inchling",
  worldcoin: "Wyrmcoin",
  "uniswap-foundation": "UniSphinx",
  "lens-protocol": "Lensprite",
  "metamask-linea": "Metapegasus",
  "aave-grants-dao": "Aavephoenix",
  "ethereum-foundation": "Etherdragon",
  zkbob: "Zephyrbat",
  "apecoin-dao": "Apedraugr",
  optimism: "Optimera",
};

export default function CardTable({ cards }: CardTableProps) {
  const [selected, setSelected] = useState<number>();

  console.log("cards", cards);
  return (
    <div className="h-full">
      <table className="h-full min-w-full text-white">
        <thead>
          <tr>
            <th
              scope="col"
              className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold  sm:pl-0"
            >
              <a href="#" className="group inline-flex">
                Card
              </a>
            </th>
            <th
              scope="col"
              className="px-3 py-3.5 text-right text-sm font-semibold "
            >
              <a href="#" className="group inline-flex">
                Supply
              </a>
            </th>
            <th
              scope="col"
              className="px-3 py-3.5 text-right text-sm font-semibold "
            >
              <a href="#" className="group inline-flex">
                Price
              </a>
            </th>
            <th
              scope="col"
              className="px-3 py-3.5 text-right text-sm font-semibold "
            >
              <a href="#" className="group inline-flex">
                Rarity
              </a>
            </th>
          </tr>
        </thead>
        <tbody>
          {cards.map((card, i) => (
            <tr
              key={i}
              className="py-2 cursor-pointer hover:bg-white/5"
              onClick={() => setSelected(i)}
            >
              <td className="whitespace-nowrap py-1 pl-4 pr-3 text-white text-sm font-medium  sm:pl-0">
                {nameMappings[card.name]}
              </td>
              <td className="whitespace-nowrap py-1 px-3 text-sm text-white/80 text-right">
                {card.supply.toString()}
              </td>
              <td className="whitespace-nowrap py-1 px-3 text-sm text-white/80 text-right">
                {priceMappings[card.rarity]} gwei
              </td>
              <td className="whitespace-nowrap py-1 px-3 text-sm text-white/80 text-right">
                {rarityMappings[card.rarity]}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <Transition.Root show={selected != undefined} as={Fragment}>
        <Dialog
          as="div"
          className="relative z-10"
          onClose={() => setSelected(undefined)}
        >
          <Transition.Child
            as={Fragment}
            enter="ease-in-out duration-500"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in-out duration-500"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black/40 transition-opacity" />
          </Transition.Child>

          <div className="fixed inset-0 overflow-hidden">
            <div className="absolute inset-0 overflow-hidden">
              <div className="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
                <Transition.Child
                  as={Fragment}
                  enter="transform transition ease-in-out duration-200 sm:duration-200"
                  enterFrom="translate-x-full"
                  enterTo="translate-x-0"
                  leave="transform transition ease-in-out duration-200 sm:duration-200"
                  leaveFrom="translate-x-0"
                  leaveTo="translate-x-full"
                >
                  <Dialog.Panel className="pointer-events-auto w-screen max-w-md">
                    <div className="flex h-full flex-col overflow-y-scroll bg-white py-6 shadow-xl">
                      <div className="px-4 sm:px-6">
                        <div className="flex items-start justify-between">
                          <Dialog.Title className="text-base font-semibold leading-6 text-gray-900">
                            Edit Card
                          </Dialog.Title>
                          <div className="ml-3 flex h-7 items-center">
                            <button
                              type="button"
                              className="rounded-md bg-white text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                              onClick={() => setSelected(undefined)}
                            >
                              <span>X</span>
                            </button>
                          </div>
                        </div>
                      </div>
                      <div className="relative mt-6 flex-1 px-4 sm:px-6 text-gray-900">
                        {selected != null && (
                          <CardDetails
                            card={cards[selected]}
                            setSelected={setSelected}
                          />
                        )}
                      </div>
                    </div>
                  </Dialog.Panel>
                </Transition.Child>
              </div>
            </div>
          </div>
        </Dialog>
      </Transition.Root>
    </div>
  );
}
