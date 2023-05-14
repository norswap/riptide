import { Fragment, useState } from "react";
import { CardProps } from "src/interfaces/card-props";
import { Dialog, Transition } from "@headlessui/react";
import { motion } from "framer-motion";
import { CardDetails } from "./card-details";

interface CardTableProps {
  cards?: CardProps[];
}

export default function CardTable({ cards }: CardTableProps) {
  const [selected, setSelected] = useState<number>();
  return (
    <>
      <table className="min-w-full ">
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
          </tr>
        </thead>
        <tbody>
          {cards.map((card, i) => (
            <tr
              key={i}
              className="py-3 cursor-pointer hover:bg-white/5"
              onClick={() => setSelected(i)}
            >
              <td className="whitespace-nowrap py-2 pl-4 pr-3 text-sm font-medium  sm:pl-0">
                {card.name}
              </td>
              <td className="whitespace-nowrap py-2 px-3 text-sm text-white/80 text-right">
                {card.quantity}
              </td>
              <td className="whitespace-nowrap py-2 px-3 text-sm text-white/80 text-right">
                ${card.price}
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
    </>
  );
}
