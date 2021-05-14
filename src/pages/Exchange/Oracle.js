import React, {Component} from 'react'

class Oracle extends Component {
    constructor(props) {
        super(props)
        this.state = {
            token: '',
            name: '',
            symbol: '',
            image: 'img',
            value: '',
            active: true
        }
    }

    handleTokenChange = async (e) => {
        const token = e.target.value.toString()
        this.setState({token: token})
    }

    handleNameChange = async (e) => {
        const name = e.target.value.toString()
        this.setState({name: name})
    }

    handleSymbolChange = async (e) => {
        const symbol = e.target.value.toString()
        this.setState({symbol: symbol})
    }

    handleValueChange = async (e) => {
        let value = e.target.value.toString()
        value = window.web3.utils.toWei(value, 'ether')
        this.setState({value: value})
    }

    render() {
        return (
            <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                this.props.updateToken(this.state.token,
                    this.state.name,
                    this.state.symbol,
                    this.state.image,
                    this.state.value,
                    this.state.active
                )
            }}>
                <div>
                    <label className="float-left"><b>Token</b></label>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        onChange={this.handleTokenChange}
                        className="form-control form-control-lg"
                        placeholder="0"
                        required/>
                </div>
                <div>
                    <label className="float-left"><b>Name</b></label>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        onChange={this.handleNameChange}
                        className="form-control form-control-lg"
                        placeholder="Name"
                        required/>
                </div>
                <div>
                    <label className="float-left"><b>Symbol</b></label>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        onChange={this.handleSymbolChange}
                        className="form-control form-control-lg"
                        placeholder="Symbol"
                        required/>
                </div>
                <div>
                    <label className="float-left"><b>Value</b></label>
                </div>
                <div className="input-group mb-4">
                    <input
                        type="text"
                        onChange={this.handleValueChange}
                        className="form-control form-control-lg"
                        placeholder="0"
                        required/>
                </div>
                <button type="submit" className="btn btn-primary btn-block btn-lg">submit</button>
            </form>
        )
    }
}

export default Oracle
