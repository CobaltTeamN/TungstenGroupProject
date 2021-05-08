<<<<<<< HEAD
import React, { createContext, useState, useEffect } from "react";
=======
import React, { createContext, useState } from "react";
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
import ContractAPI from "./api/contractAPI";

export const GlobalState = createContext();

export const DataProvider = ({ children }) => {
  const [useContract, setUseContract] = useState(false);

<<<<<<< HEAD
  useEffect(() => {}, []);

  const state = {
    useContract: [useContract, setUseContract],
    contractAPI: ContractAPI(useContract),
    loading: true,
  };

  return <GlobalState.Provider value={state}>{children}</GlobalState.Provider>;
=======

  const state = {
    useContract: [useContract, setUseContract],
    contractAPI: ContractAPI(),

  };
  ContractAPI();
  return (
  <GlobalState.Provider value={state}>
    {children}
    </GlobalState.Provider>
  );
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
};
