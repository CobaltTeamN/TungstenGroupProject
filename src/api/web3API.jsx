import { useState, useEffect } from 'react';
import Web3 from 'web3'

function Web3API() {
    const [isLoggedIn, setIsLoggedIn] = useState(false)
    const [userWeb3, setUserWeb3] = useState(null)
    const [ethBalance, setEthBalance] = useState()

    useEffect(() => {
        async function fetchData() {
            await loadWeb3()
        }
        fetchData()
    }, []) // eslint-disable-line react-hooks/exhaustive-deps


    
    // Detect Meta Mask Accounts
    // For now, 'eth_accounts' will continue to always return an array
    // function handleAccountsChanged(accounts) {
    //     console.log(accounts);
    //     if (accounts.length === 0) {
    //         // MetaMask is locked or the user has not connected any accounts
    //         console.log("Please connect to MetaMask.");
    //         setIsLoggedIn(false)
    //     } else {
    //         setUserWeb3(accounts[0]);
    //         setIsLoggedIn(true)
    //     }
    // }

    const loadWeb3 = async () => {
        // if (typeof window.ethereum !== "undefined") {
        //     // ethereum,enable() is depericated
        //     await window.ethereum
        //       .request({ method: "eth_accounts" })
        //       .then(handleAccountsChanged)
        //       .catch((err) => {
        //         // For backwards compatibility reasons, if no accounts are available,
        //         // eth_accounts will return an empty array.
        //         console.error(err);
        //       });
      
        //     // Current ethereum object
        //     const web3 = new Web3(window.ethereum);
      
        //     // Current Metamask network in use
        //     const netId = await web3.eth.net.getId();
        //     switch (netId) {
        //       case 1:
        //         console.log("This is mainnet");
        //         break;
        //       case 4:
        //         console.log("This is the Rinkeby test network.");
        //         break;
        //       case 5777:
        //         console.log("This is the Ganache test network.");
        //         break;
        //       default:
        //         console.log("This is an unknown network.");
        //     }
      
        //     // Current Metamask Account
        //     const accounts = await web3.eth.getAccounts();
        //     if (typeof accounts[0] !== "undefined") {
        //       const bal = await web3.eth.getBalance(accounts[0]);
        //       setEthBalance(bal)
        //       setUserWeb3(accounts[0]);
        //       setIsLoggedIn(true)
        //     } else {
        //       window.alert("Please login with MetaMask");
        //       setIsLoggedIn(false)
        //     }
        //   }
        //   // If Metmask is not detected
        //   else {
        //     window.alert("Please install MetaMask");
        //     setIsLoggedIn(false)
        //   }
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum)
           const web3instance =  await window.ethereum.enable();
           const accounts = await window.web3.eth.getAccounts();
           const bal = await window.web3.eth.getBalance(accounts[0]);
           setEthBalance(bal)
           setUserWeb3(web3instance)
           setIsLoggedIn(true)
        }
        else if (window.web3) {
          window.web3 = new Web3(window.web3.currentProvider)
          setIsLoggedIn(true)
        }
        else {
            window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    }


    return {
        isLoggedIn: [isLoggedIn, setIsLoggedIn],
        userWeb3: [userWeb3, setUserWeb3],
        ethBalance: [ethBalance, setEthBalance],
        loadWeb3: loadWeb3,
    }


}

export default Web3API;