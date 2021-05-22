import { useState, useEffect } from 'react';
import Chromium from '../abis/Chromium.json';
import Oracle from '../abis/ExchangeOracle.json';
import IERC20 from '../abis/IERC20.json';

function ExchangeAPI() {
    const [account, setAccount] = useState()
    const [ethBalance, setEthBalance] = useState()
    const [ierc20, setIERC20] = useState()
    const [chromium, setChromium] = useState()
    const [oracle, setOracle] = useState()
    const [loading, setLoading] = useState(true)
    const [fromToken, setFromToken] = useState()
    const [amount, setAmount] = useState()
    const [ethAddress, setEthAddress] = useState()
    const [tokenAddress, setTokenAddress] = useState();

    useEffect(() => {
        async function loadData() {
            await loadBlockchainData()
        }
        loadData()
    }, [account])


    const loadBlockchainData = async () => {
        const web3 = window.web3

        const accounts = await web3.eth.getAccounts()
        setAccount(accounts[0])

        const ethBalance = await web3.eth.getBalance(accounts[0])
        setEthBalance(ethBalance)

        // Load Token
        const networkId = await web3.eth.net.getId()

        const ierc20Data = IERC20.networks[networkId]
        if(ierc20Data) {
            const erc = new web3.eth.Contract(IERC20.abi, ierc20Data)
            setIERC20(erc)
        }

        // Chromium Contract
        const chromiumData = Chromium.networks[networkId]
        if (chromiumData) {
            const chromium = new web3.eth.Contract(Chromium.abi, chromiumData.address)
            setChromium(chromium)
        } else {
            window.alert('Chromium contract not deployed to detected network.')
        }
        
        // Oracle Contract
        const oracleData = Oracle.networks[networkId]
        if(oracleData) {
            const oracle = new web3.eth.Contract(Oracle.abi, oracleData.address)
            setOracle(oracle)
        } else {
            window.alert("Oracle contract not deployed to detected network")
        }

        setLoading(false)
    }
    const swapForCblt = () => {
        setLoading(true)
        if(tokenAddress !== null && amount !== '' && amount !== 0) {
            console.log('in there')
            // Handle Ether Transaction
            if(tokenAddress === ethAddress && amount !== 0 && amount !== '') {
                try{
                    console.log(tokenAddress)
                    let etherAmount
                    etherAmount = amount
                    console.log(etherAmount)
                    etherAmount = window.web3.utils.toWei(etherAmount, "ether")
                    console.log(etherAmount)
                    chromium.methods.swapForCblt('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE', "100000000000000000").send({
                        value: etherAmount,
                        from: account
                    }).on('transactionHash', (hash) => {
                        this.setState({loading: false})
                    })
                } catch (e) {
                    console.log("Error, deposit: ", e);
                }
            } else {
                console.log('in there there')
                try {
                    let etherAmount
                    etherAmount = amount
                    console.log('ether')
                    console.log(amount)
                    etherAmount = window.web3.utils.toWei(etherAmount, "ether")
                    console.log('ether convert')
                    console.log(etherAmount)
                    chromium.methods.swapForCblt('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE', etherAmount).send({
                        from: account
                    }).on('transactionHash', (hash) => {
                        setLoading(false)
                    })
                } catch (e) {
                    console.log("Error, deposit: ", e);
                }
            }
        } else {
            setLoading(false)
        }
    }


    return {
        tokenAddress: [tokenAddress, setTokenAddress],
        fromToken: [fromToken, setFromToken],
        amount: [amount, setAmount],
        ethAddress: [ethAddress, setEthAddress],
        account: [account, setAccount],
        ierc20: [ierc20, setIERC20],
        loadBlockchainData: loadBlockchainData,
        ethBalance: [ethBalance, setEthBalance],
        chromium: [chromium, setChromium],
        oracle: [oracle, setOracle],
        loading: [loading, setLoading],
        swapForCblt: swapForCblt,
    }


}

export default ExchangeAPI;