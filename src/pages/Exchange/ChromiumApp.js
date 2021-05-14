import React, {Component} from 'react'
import Web3 from 'web3'
import Chromium from '../../abis/Chromium.json'
import Oracle from '../../abis/ExchangeOracle.json'
import navBar from '../../components/navBar'
import Main from './ChromiumMain'
import axios from 'axios'

const approveURL = 'https://api.1inch.exchange/v3.0/1/approve/calldata';
let callURL = 'https://api.1inch.exchange/v3.0/1/swap'
const ethereumMainnet = {'chain': 'mainnet'}


class App extends Component {


    async componentWillMount() {
        await this.loadWeb3()
        await this.loadBlockchainData()
    }
    async loadBlockchainData() {
        const web3 = window.web3

        const accounts = await web3.eth.getAccounts()
        this.setState({account: accounts[0]})

        const ethBalance = await web3.eth.getBalance(this.state.account)
        this.setState({ethBalance})

        // Load Token
        const networkId = await web3.eth.net.getId()

        const chromiumData = Chromium.networks[networkId]
        if (chromiumData) {
            const chromium = new web3.eth.Contract(Chromium.abi, chromiumData.address)
            this.setState({chromium})
        } else {
            window.alert('Chromium contract not deployed to detected network.')
        }

        const oracleData = Oracle.networks[networkId]
        if(oracleData) {
            const oracle = new web3.eth.Contract(Oracle.abi, oracleData.address)
            this.setState({oracle})
        } else {
            window.alert("Oracle contract not deployed to detected network")
        }

        this.setState({loading: false})
    }

    async loadWeb3() {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.enable()
        } else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider)
        } else {
            window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    }

    buyTokens = (etherAmount) => {
        this.setState({loading: true})
        this.state.ethSwap.methods.buyTokens().send({
            value: etherAmount,
            from: this.state.account
        }).on('transactionHash', (hash) => {
            this.setState({loading: false})
        })
    }

    sellTokens = (tokenAmount) => {
        this.setState({loading: true})
        this.state.token.methods.approve(this.state.ethSwap.address, tokenAmount).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.state.ethSwap.methods.sellTokens(tokenAmount).send({from: this.state.account}).on('transactionHash', (hash) => {
                this.setState({loading: false})
            })
        })
    }

    getCbltExchangeRate = async (fromToken, cbltToken, amount) => {
        this.setState({loading: true})
        await this.state.chromium.methods.getCbltExchangeRate(fromToken, cbltToken, amount).call({from: this.state.account})
            .then((results) => {
                let res = results / 1000
                this.setState({returnAmount: res.toString()})
            })
        this.setState({loading: false})
    }

    swapForCblt = (fromToken, destToken, amount, returnAmount) => {
        this.setState({loading: true})
        if(fromToken === this.state.ethAddress) {
            this.state.chromium.methods.swapForCblt(fromToken, destToken, amount, returnAmount).send({
                value: amount,
                from: this.state.account
            }).on('transactionHash', (hash) => {
                this.setState({loading: false})
            })
        } else {
            fromToken.methods.approve(this.state.chromium.address, amount).send({
                from: this.state.account
            }).on('transactionHash', (hash) => {
                this.state.chromium.methods.swapForCblt(fromToken, destToken, amount, returnAmount).send({
                    from: this.state.account
                }).on('transactionHash', (hash) => {
                    this.setState({loading: false})
                })
            })
        }
    }

    updateToken = (token, name, symbol, image, value, active) => {
        this.setState({loading: false})
        this.state.oracle.methods.updateToken(token, name, symbol, image, value, active).send({
            from: this.state.account
        }).on("transactionHash", (hash) => {
            this.setState({loading: false})
        })
    }

    sendTransaction = (tx) => {
        let temp = '0x' + tx.toString('hex');
        window.web3.eth.sendSignedTransaction(temp).on('receipt', console.log)
    }

    signTx = (tx) => {
        let temp= window.web3.eth.signTransaction(tx, this.state.account, (err, res) => {})
        console.log(temp)
        return temp
    }

    approveApiCaller = async (url, value, tokenAddress, nonce) => {
        url += (value > -1 || value != null ? "?amount=" + value + "&" : "") //tack on the value if it's greater than -1
            + "tokenAddress=" + tokenAddress             //complete the called URL
        console.log(url);
        let temp = await axios.get(url);                //wait for the request to be complete

        temp = temp.data;                               //we only want the data object from the api call
        //we need to convert the gas price to hex
        let gasPrice = parseInt(temp["gasPrice"]);
        console.log(gasPrice)
        gasPrice = '0x' + gasPrice.toString(16);        //convert to hexadecimal string
        temp["value"] = "0x" + temp["value"];           //convert value to hecadecimal
        temp["gasPrice"] = gasPrice;                    //change the gas price in the tx object
        temp["gas"] = "0xc350";                         //gas limit of 50,000, may need to be higher for certain tokens
        temp["from"] = this.state.account;
        temp["nonce"] = nonce;
        return temp;
    }

    apiCaller = async (url, fromToken, destToken, amount, slippage, nonce) => {
        let temp = await axios.get(url, { params: {
                fromTokenAddress: fromToken,
                toTokenAddress: destToken,
                amount: amount,
                fromAddress: this.state.account,
                slippage: slippage
            }
        });                //get the api call
        temp = temp.data;                               //we only want the data object from the api call
        //we need to convert the gasPrice to hex
        let gasPrice = parseInt(temp.tx["gasPrice"]);   //get the gasPrice from the tx
        gasPrice = '0x' + gasPrice.toString(16);        //add a leading 0x after converting from decimal to hexadecimal
        temp.tx["gasPrice"] = gasPrice;                 //set the value of gasPrice in the transaction object
        //we also need value in the form of hex
        let value = parseInt(temp.tx["value"]);			    //get the value from the transaction
        value = '0x' + value.toString(16);				      //add a leading 0x after converting from decimal to hexadecimal
        temp.tx["value"] = value;						            //set the value of value in the transaction object
        temp.tx["nonce"] = nonce;                       //it's the users responsibility to keep track of the nonce
        return temp;                                    //return the data
    }

    driver = async (fromToken, destToken, amount, slippage) => {
        let globalData = await this.approveApiCaller(approveURL, amount, fromToken, "0xfe");
        console.log(globalData);
        let transaction = this.signTx(globalData);               //sign the transaction with
        console.log(transaction);                       //print the serialized transaction
        this.sendTransaction(transaction);                   //send the transaction
        globalData = await this.apiCaller(callURL, fromToken, destToken, amount, slippage, '0xff');  //call the api to get the data, and wait until it returns
        console.log(globalData["tx"]);                  //log the data
        transaction = this.signTx(globalData["tx"]);         //sign the transaction
        console.log(transaction);                       //print the bytes
        this.sendTransaction(transaction);                   //send the transaction
        console.log("transaction success");
    }


    constructor(props) {
        super(props)
        this.state = {
            account: '',
            token: {},
            ethSwap: {},
            chromium: {},
            oracle: {},
            ethAddress: '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',
            fromToken: '',
            destToken: '',
            amount: '',
            slippage: '',
            returnAmount: '',
            tokenBalance: '',
            ethBalance: '',
            loading: true
        }
    }

    render() {
        let content
        if (this.state.loading) {
            content = <p id="loader" className="text-center">Loading...</p>
        } else {
            content = <Main
                fromToken={this.state.fromToken}
                destToken={this.state.destToken}
                amount={this.state.amount}
                slippage={this.state.slippage}
                returnAmount={this.state.returnAmount}
                swapForCblt={this.swapForCblt}
                getCbltExchangeRate={this.getCbltExchangeRate}
                driver={this.driver}
                tokenBalance={this.state.tokenBalance}
                ethBalance={this.state.ethBalance}
                updateToken={this.updateToken}
            />
        }

        return (
            <div>
                <navBar account={this.state.account}/>
                <div className="container-fluid mt-5">
                    <div className="row">
                        <main role="main" className="col-lg-12 ml-auto mr-auto" style={{maxWidth: '600px'}}>
                            <div className="content mr-auto ml-auto">
                                <a
                                    href="http://www.dappuniversity.com/bootcamp"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                >
                                </a>

                                {content}

                            </div>
                        </main>
                    </div>
                </div>
            </div>
        );
    }
}

export default App;
