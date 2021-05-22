import React, {Component} from 'react'
import Web3 from 'web3'
import Chromium from '../../abis/Chromium.json'
import Oracle from '../../abis/ExchangeOracle.json'
import navBar from '../../components/navBar'
import IERC20 from '../../abis/IERC20.json'
import Main from './ChromiumMain'


class App extends Component {

    constructor(props) {
        super(props)
        this.state = {
            account: '',
            token: {},
            chromium: {},
            ierc20: {},
            oracle: {},
            chainId: '',
            ethAddress: '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',
            cbltToken: '0xAA9E1c266B6A62314A6f8c1EE347991Ceb8b6690',
            fromToken: null,
            destToken: null,
            amount: '0',
            returnAmount: '',
            tokenBalance: '',
            ethBalance: '',
            uniswapQuote: '',
            loading: true
        }

        // this.quote = this.quote.bind(this)
        this.swapForCblt = this.swapForCblt.bind(this)
        this.getCbltExchangeRate = this.getCbltExchangeRate.bind(this)
        this.updateToken = this.updateToken.bind(this)
    }

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
        this.setState({chainId: networkId})

        const ierc20Data = IERC20.networks[networkId]
        if(ierc20Data) {
            const ierc20 = new web3.eth.Contract(IERC20.abi, ierc20Data)
            this.setState({ierc20})
        }

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

    handleInput = (e) => {
        let name = e.target.name
        let value = e.target.value
        this.setState({
            [name]: value
        });
        console.log(name, value)
    };

    getCbltExchangeRate() {
        this.setState({loading: true})
        if(this.state.fromToken !== null && this.state.amount !== 0 && this.state.amount !== '') {
            console.log(this.state.fromToken)
            this.state.chromium.methods.getCbltExchangeRate(this.state.fromToken, this.state.cbltToken, this.state.amount).call({from: this.state.account})
                .then((results) => {
                    let res = results / 1000000
                    this.setState({
                        returnAmount: res.toString()
                    })
                })
            this.setState({loading: false})
        } else {
            this.setState({loading: false})
        }
    }

    swapForCblt() {
        console.log('what')
        this.setState({loading: true})
        if(this.state.fromToken !== null && this.state.amount !== '' && this.state.amount !== 0) {
            console.log(this.state.amount)
            console.log(this.state.account)
            console.log(this.state.fromToken)
            console.log('in there')
            // Handle Ether Transaction
            if(this.state.fromToken === this.state.ethAddress && this.state.amount !== 0 && this.state.amount !== '') {
                try{
                    let etherAmount
                    etherAmount = this.state.amount
                    console.log(etherAmount)
                    etherAmount = window.web3.utils.toWei(etherAmount, "ether")
                    console.log(etherAmount)
                    console.log(this.state.chromium)
                    this.state.chromium.methods.swapForCblt(this.state.fromToken, "100000000000000000").send({
                        value: etherAmount,
                        from: this.state.account
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
                    etherAmount = this.state.amount
                    console.log('ether')
                    console.log(etherAmount)
                    etherAmount = window.web3.utils.toWei(etherAmount, "ether")
                    console.log('ether convert')
                    console.log(etherAmount)
                    this.state.chromium.methods.swapForCblt(this.state.fromToken, etherAmount).send({
                        from: this.state.account
                    }).on('transactionHash', (hash) => {
                        this.setState({loading: false})
                    })
                } catch (e) {
                    console.log("Error, deposit: ", e);
                }
                // this.state.ierc20.methods.approve(this.state.chromium.address, etherAmount).send({
                //     from: this.state.account
                // }).on('transactionHash', (hash) => {

                // })
            }
        } else {
            this.setState({loading: false})
        }
    }

    async updateToken(token, name, symbol, image, value, active) {
        this.setState({loading: false})
        await this.state.oracle.methods.updateToken(token, name, symbol, image, value, active).send({
            from: this.state.account
        }).on("transactionHash", (hash) => {
            this.setState({loading: false})
        })
    }

    async swapCbltForToken() {

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
                returnAmount={this.state.returnAmount}
                swapForCblt={this.swapForCblt}
                getCbltExchangeRate={this.getCbltExchangeRate}
                tokenBalance={this.state.tokenBalance}
                ethBalance={this.state.ethBalance}
                updateToken={this.updateToken}
                handleInput={this.handleInput}
                ethAddress={this.state.ethAddress}
                cbltToken={this.state.cbltToken}
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
