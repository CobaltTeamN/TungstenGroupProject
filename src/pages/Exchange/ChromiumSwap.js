import React, {Component} from 'react'

const fromOptions =
    <>
        <option>...</option>
        <option value={"0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"}>ETH</option>
        <option value={"0x111111111117dc0aa78b770fa6a738034120c302"}>One Inch</option>
        <option value={"0x55d398326f99059ff775485246999027b3197955"}>USDT</option>
        <option value={"0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d"}>USDC</option>
        <option value={'0x6b175474e89094c44da98b954eedeac495271d0f'}>DIA</option>
    </>


class ChromiumSwap extends Component {
    constructor(props) {
        super(props)
    }

    handleChange = (e) => {
        e.preventDefault()
        this.props.getCbltExchangeRate()
    }

    handleSubmit = (e) => {
        e.preventDefault()
        this.props.swapForCblt()
    }

    render() {
        return (
            <form className="mb-3" onSubmit={this.handleSubmit}>
                <div>
                    <label className="float-left"><b>Input</b></label>
                    <span className="float-right text-muted">
            Balance: {window.web3.utils.fromWei(this.props.ethBalance, 'Ether')}
          </span>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        name='amount'
                        onChange={this.props.handleInput}
                        ref={(input) => { this.input = input }}
                        className="form-control form-control-lg"
                        placeholder='0'
                    />
                    <div className="input-group-append">
                        <div className="input-group-text">
                            <select
                                name='fromToken'
                                onChange={this.props.handleInput}>
                                {fromOptions}
                            </select>
                        </div>
                    </div>
                </div>
                <div>
                    <label className="float-left"><b>Output</b></label>
                    <span className="float-right text-muted">
            Balance: {window.web3.utils.fromWei(this.props.tokenBalance, 'Ether')}
          </span>
                </div>
                <div className="input-group mb-2">
                    <input
                        type="text"
                        className="form-control form-control-lg"
                        placeholder="0"
                        value={this.props.returnAmount}
                        disabled
                    />
                    <div className="input-group-append">
                        <div className="input-group-text">
                            &nbsp; CBLT
                        </div>
                    </div>
                </div>
                <button type="submit" onClick={this.handleChange} className="btn btn-primary btn-block btn-lg">Quote</button>
                <button type="submit" className="btn btn-primary btn-block btn-lg">SWAP!</button>
            </form>
        );
    }
}

export default ChromiumSwap;
