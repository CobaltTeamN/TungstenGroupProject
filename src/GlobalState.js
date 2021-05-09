<<<<<<< HEAD
<<<<<<< HEAD
import React, { createContext, useState, useEffect } from "react";
=======
import React, { createContext, useState } from "react";
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
import React, { createContext, useState } from "react";
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
import ContractAPI from "./api/contractAPI";

export const GlobalState = createContext();

export const DataProvider = ({ children }) => {
  const [useContract, setUseContract] = useState(false);

<<<<<<< HEAD
<<<<<<< HEAD
  useEffect(() => {}, []);

  const state = {
    useContract: [useContract, setUseContract],
    contractAPI: ContractAPI(useContract),
    loading: true,
  };

  return <GlobalState.Provider value={state}>{children}</GlobalState.Provider>;
=======
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2

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
<<<<<<< HEAD
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
};
