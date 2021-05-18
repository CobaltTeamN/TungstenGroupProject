/* eslint-disable */
import Web3 from "web3";
import Bank from "./abis/Bank.json";
import CHC from "./abis/CHCToken.json";
import Wood from "./abis/WoodToken.json";
import Smit from "./abis/SmitCoin.json";
import Slick from "./abis/Token.json";
import Ham from "./abis/HAM.json";
import Chromium from "./abis/Chromium.json";
import { useState, useEffect } from "react";
import Swap from "./components/exchange";
import Router from "./components/Router/Router";
import { Link } from "react-router-dom";
import Sidebar from "./components/Sidebar";
import { BrowserRouter, Switch, Route } from "react-router-dom";
import styled, { ThemeProvider } from "styled-components";
import NavBar from "./components/navBar";

const theme = {
  grayText: "#6b7774",
};

export default function NewApp() {
  const [userWeb3, setUserWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [stateWeb3, setWeb3] = useState(null);
  const [sToken, setToken] = useState(null);
  const [sCoinAddress, setCoinAddress] = useState(null);
  const [balance, setBalance] = useState(null);
  const [allContracts, setAllContracts] = useState(null);

  const abiArr = [Bank, CHC, Wood, Slick, Ham, Smit, Chromium];
  useEffect(() => {
    async function callData() {
      await loadBlockchainData();
    }
    // callData();
  }, []);
  let currentAccount = null;

  async function loadBlockchainData() {
    if (typeof window.ethereum !== "undefined") {
      // ethereum,enable() is depericated
      await window.ethereum
        .request({ method: "eth_accounts" })
        .then(handleAccountsChanged)
        .catch((err) => {
          // For backwards compatibility reasons, if no accounts are available,
          // eth_accounts will return an empty array.
          console.error(err);
        });

      // Current ethereum object
      const web3 = new Web3(window.ethereum);

      // Current Metamask network in use
      const netId = await web3.eth.net.getId();
      switch (netId) {
        case 1:
          console.log("This is mainnet");
          break;
        case 4:
          console.log("This is the Rinkeby test network.");
          break;
        case 5777:
          console.log("This is the Ganache test network.");
          break;
        default:
          console.log("This is an unknown network.");
      }

      // Current Metamask Account
      const accounts = await web3.eth.getAccounts();
      if (typeof accounts[0] !== "undefined") {
        const bal = await web3.eth.getBalance(accounts[0]);
        setAccount(accounts[0]);
        setWeb3(web3);
      } else {
        window.alert("Please login with MetaMask");
      }
      loadContracts(web3);
    }
    // If Metmask is not detected
    else {
      window.alert("Please install MetaMask");
    }
  }

  // Detect Meta Mask Accounts
  // For now, 'eth_accounts' will continue to always return an array
  function handleAccountsChanged(accounts) {
    console.log(accounts);
    if (accounts.length === 0) {
      // MetaMask is locked or the user has not connected any accounts
      console.log("Please connect to MetaMask.");
    } else if (accounts[0] !== currentAccount) {
      currentAccount = accounts[0];
    }
  }

  function loadContracts(web3) {
    try {
      //Load Bank Protocol
      // const token = new web3.eth.Contract(
      //   Bank.abi,
      //   Bank.networks[netId].address
      // );
      // console.log(token)
      // setToken(token);
      //Load single token
      // const coinAddress = CHC.networks[netId].address;
      // console.log(coinAddress)
      // setCoinAddress(coinAddress);
      // await token.methods
      //   .balanceOf()
      //   .call({ from: accounts[0] })
      //   .then((result) => {
      //     console.log(result.toString());
      //     setBalance(result.toString());
      //   });
      // Array of tokens
      // const tempContractArr = [];
      // for (let i = 0; i < abiArr.length; i++) {
      //   tempContractArr.push(
      //     new web3.eth.Contract(
      //       abiArr[i].abi,
      //       abiArr[i].networks[netId].address
      //     )
      //   );
      // }
      // setAllContracts(tempContractArr);
    } catch (e) {
      console.log("Error", e);
      window.alert("Contracts not deployed to the current network");
    }
  }

  //Add Token to MetaMask
  async function addToken() {
    const tokenAddress = "0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e";
    const tokenSymbol = "cblt";
    const tokenDecimals = 18;
    const tokenImage = "https://i.imgur.com/rRTK4EH.png";

    try {
      // wasAdded is a boolean. Like any RPC method, an error may be thrown.
      const wasAdded = await window.ethereum.request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC20", // Initially only supports ERC20, but eventually more!
          options: {
            address: tokenAddress, // The address that the token is at.
            symbol: tokenSymbol, // A ticker symbol or shorthand, up to 5 chars.
            decimals: tokenDecimals, // The number of decimals in the token
            image: tokenImage, // A string url of the token logo
          },
        },
      });

      if (wasAdded) {
        console.log("Thanks for your interest!");
      } else {
        console.log("Your loss!");
      }
    } catch (error) {
      console.log(error);
    }
  }

  useEffect(async () => {
    // const fetchData = async () => {
    // }
    // fetchData();
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <BrowserRouter>
        <NavBar />
        <Sidebar />
        <div style={{ marginLeft: "240px" }}>
          <SRouter />
        </div>
      </BrowserRouter>
    </ThemeProvider>
  );
}
const SRouter = styled(Router)`
  margin-right: 240px;
`;

async function getToken(str) {
  switch (str) {
    case "CHC":
      return CHC;
    case "Wood":
      return Wood;
    case "Slick":
      return Slick;
  }
}
