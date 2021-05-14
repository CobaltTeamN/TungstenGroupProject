import React, {Component} from 'react'
import OneInchSwap from './OneInchSwap'
import ChromiumSwap from './ChromiumSwap'
import Oracle from "./Oracle";

class Main extends Component {
    constructor(props) {
        super(props)
        this.state = {
            currentForm: 'CBLT'
        }
    }

    render() {
        let content
        if (this.state.currentForm === 'CBLT') {
            content = <ChromiumSwap
                getCbltExchangeRate={this.props.getCbltExchangeRate}
                swapForCblt={this.props.swapForCblt}
                returnAmount={this.props.returnAmount}
                sellTokens={this.props.sellTokens}
                tokenBalance={this.props.tokenBalance}
                ethBalance={this.props.ethBalance}
            />
        } else {
            content = <OneInchSwap
                slippage={this.props.slippage}
                driver={this.props.driver}
            />
        }

        return (
            <div id="content" className="mt-3">

                <div className="d-flex justify-content-between mb-3">
                    <button
                        className="btn btn-light"
                        onClick={(event) => {
                            this.setState({currentForm: 'CBLT'})
                        }}
                    >
                        CBLT
                    </button>
                    <span className="text-muted">&lt; &nbsp; &gt;</span>
                    <button
                        className="btn btn-light"
                        onClick={(event) => {
                            this.setState({currentForm: 'ONEINCH'})
                        }}
                    >
                        ONE INCH
                    </button>
                </div>

                <div className="card mb-4">

                    <div className="card-body">

                        {content}

                    </div>

                </div>
                <div>
                    <Oracle
                        updateToken={this.props.updateToken}
                    />
                </div>

            </div>
        );
    }
}

export default Main;
