import React, {useEffect, useState} from 'react'
import {Container} from 'react-bootstrap'
import Web3 from 'web3';
import NFTScore from '../../abis/NFTLoan.json'
// import Slick from '../../abis/HAM.json'
import NFTScoring from '../../components/nft/nftScoring';

const NFT = () => {
    const [account, setAccount] = useState('');
    // const [contract, setContract] = useState(null);
    // const [totalSupply, setTotalSupply] = useState(0);
   
    const loadWeb3 = async () => {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.enable()
        }
        else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider)
        }
        else {
            window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    }

    const loadBlockchainData = async () => {
        const web3 = window.web3;
    // Load account
        const accounts = await web3.eth.getAccounts()
        setAccount(accounts[0])
        console.log(accounts[0])

        // Current Metamask network in use
        const netId = await web3.eth.net.getId();
        switch (netId) {
          case 1:
            console.log('This is mainnet')
            break
          case 4:
            console.log('This is the Rinkeby test network.')
            break
          case 5777:
            console.log('This is the Ganache test network.')
            break
          default:
            console.log('This is an unknown network.')
        }
  
       
        const networkData = NFTScore.networks[netId]
        // console.log(networkData)


        const abi = NFTScore.abi
        console.log(networkData)
        // const contract = new web3.eth.Contract(abi, address)

        console.log(abi)
        if (networkData) {
            // const abi = NFTScore.abi
            // const address = networkData.address
            // const contract = new web3.eth.Contract(abi, address)
            // setContract(contract)
            // const totalSupply = await contract.methods.totalSupply().call()
            // setTotalSupply(totalSupply)

        } else {
            window.alert('Smart contract not deployed to detected network.')
        }
    }
      useEffect(() => {
        const fetchData = async () => {
       await loadWeb3()
        await loadBlockchainData();
        }
        fetchData();
      }, [account]);

  return (
    <Container>    
     <NFTScoring/>
    </Container>
  )

};

export default NFT;
