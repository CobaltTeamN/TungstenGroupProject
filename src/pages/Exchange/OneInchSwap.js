import React, {Component} from 'react'
import axios from 'axios'

const oneInchAPI = 'https://api.1inch.exchange/v3.0/1/quote'

const fromOptions =
    <>
        <option value={"0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"}>ETH</option>
        <option value={"0x111111111117dc0aa78b770fa6a738034120c302"}>One Inch</option>
        <option value={"0x55d398326f99059ff775485246999027b3197955"}>USDT</option>
        <option value={"0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d"}>USDC</option>
        <option value={'0x6b175474e89094c44da98b954eedeac495271d0f'}>DIA</option>
    </>

const destOptions =
    <>
        <option value={"0xdac17f958d2ee523a2206206994597c13d831ec7"}>USDT</option>
        <option value={"0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d"}>USDC</option>
        <option value={'0x6b175474e89094c44da98b954eedeac495271d0f'}>DIA</option>
        <option value={"0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"}>ETH</option>
        <option value={"0x111111111117dc0aa78b770fa6a738034120c302"}>One Inch</option>
    </>


class OneInchSwap extends Component {
    constructor(props) {
        super(props)
        this.state = {
            fromToken: '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',
            destToken: '0xdac17f958d2ee523a2206206994597c13d831ec7',
            fromTokenBalance: '',
            destTokenBalance: '',
            amount: '',
            slippage: '1',
            returnAmount: ''
        }
    }

    handleFromTokenChange = async (e) => {
        let {name, value} = e.target
        console.log(value)
        this.setState({fromToken: value})
        if(this.state.amount !== '') {
            let temp = await axios.get(oneInchAPI, {
                params: {
                    fromTokenAddress: this.state.fromToken,
                    toTokenAddress: this.state.destToken,
                    amount: this.state.amount,
                    responseType:'text'
                }
            })
            temp = temp.data.toTokenAmount
            this.setState({
                returnAmount: temp,
            })
        }
    }

    handleFromTokenAmountChange = async () => {
        const amount = this.input.value.toString()
        this.setState({amount: amount})
        console.log(amount)
        let temp = await axios.get(oneInchAPI, {
            params: {
                fromTokenAddress: this.state.fromToken,
                toTokenAddress: this.state.destToken,
                amount: amount
            }
        })
        temp = temp.data.toTokenAmount
        console.log(temp)
        this.setState({
            returnAmount: temp
        })
    }

    handleDestTokenChange = async (e) => {
        let {name, value} = e.target
        this.setState({destToken: value})
        if(this.state.amount !== '') {
            let temp = await axios.get(oneInchAPI, {
                params: {
                    fromTokenAddress: this.state.fromToken,
                    toTokenAddress: this.state.destToken,
                    amount: this.state.amount,
                    responseType:'text'
                }
            })
            temp = temp.data.toTokenAmount
            this.setState({
                returnAmount: temp,
            })
        }
    }

    render() {
        return (
            <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                this.props.driver(this.state.fromToken, this.state.destToken, this.state.amount, this.state.slippage)
            }}>
                <div>
                    <label className="float-left"><b>Input</b></label>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        onChange={this.handleFromTokenAmountChange}
                        ref={(input) => {
                            this.input = input
                        }}
                        className="form-control form-control-lg"
                        placeholder="0"
                        required/>
                    <div className="input-group-append">
                        <div className="input-group-text">
                            <select onChange={this.handleFromTokenChange}>
                                {fromOptions}
                            </select>
                        </div>
                    </div>
                </div>
                {/*      <span className="float-right text-muted">*/}
                {/*  Balance: {window.web3.utils.fromWei(this.props.fromTokenBalance, 'Ether')}*/}
                {/*</span>*/}
                <div>
                    <label className="float-left"><b>Output</b></label>
                </div>
                <div className="input-group mb-2">
                    <input
                        type="text"
                        className="form-control form-control-lg"
                        placeholder="0"
                        value={this.state.returnAmount}
                        disabled
                    />
                    <div className="input-group-append">
                        <div className="input-group-text">
                            <select onChange={this.handleDestTokenChange}>
                                {destOptions}
                            </select>
                        </div>
                    </div>
                </div>
                <div className="mb-5">
                    <span className="float-left text-muted">Exchange Rate</span>
                    <span className="float-right text-muted">{}</span>
                </div>
                <button type="submit" className="btn btn-primary btn-block btn-lg">SWAP!</button>
            </form>
        );
    }
}

export default OneInchSwap;
