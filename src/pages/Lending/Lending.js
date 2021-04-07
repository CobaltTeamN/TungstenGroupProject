import Loader from "./Loader";
import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";
import LendingApp from "./LendingApp";
import NavBar from "../../components/navBar";

const Lending = (props) => {
  const state = useContext(GlobalState);
  return (
    <div>
      <Loader></Loader>
      <LendingApp></LendingApp>
    </div>
  );
};

export default Lending;
