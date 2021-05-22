import React, { useState, useContext } from 'react';
import Gear from '../icons/settings.svg'
import Arrow from '../icons/arrow-down.svg'
import Down from '../icons/chevron-down.svg'
import { TokenSelection } from './tokenSelection';
import { GlobalState } from '../GlobalState';

import './exchange.css';

const Swap = (props) => {
  const state = useContext(GlobalState)
  const [metaMaskAddress] = state.web3API.userWeb3[0];
  const swapForCblt = state.exchangeAPI.swapForCblt;
  const [modalShow, setModalShow] = useState(false);
  const setAmount= state.exchangeAPI.amount[1];

  console.log(state)
  if(!state) {
    console.log(metaMaskAddress)
  }
  function handleInput(e) {
    let value = e.target.value
    setAmount(value.toString());
  };

  function handleSubmit(e) {
    e.preventDefault()
    swapForCblt()
}

  return (
    <div className="swapwrapper mt-5">
      <form className="swapcard"  onSubmit={handleSubmit}>
        <div className="cardtitle ml-4 mt-2 mb-3 mr-4">
          <h5>Swap</h5>
          <img alt="gear" src={Gear} />
        </div>
        <div className="swapfrom  ml-4 mr-4">
          <div className="m-atuo">
            <p>From</p>
            <input
              className="form-input"
              type="number"
              placeholder="0.0"
              onChange={handleInput}
            ></input>
          </div>
          <div>
            <div className="balancediv pb-2">
              <p >Balance</p>
              <div className="form-input balance pl-2 " >
                {"5.00" +
                  " " +
                  "CBLT"}
              </div>
            </div>
            <div style={{ display: 'flex' }}>
              {/* <button className="tokenbtn choice" type="submit"
                onClick={() => setModalShow(true)}>
                {"CBLT"}  <img src={Down} alt="downarrow" />
              </button>
              <TokenSelection
                show={modalShow}
                onHide={() => setModalShow(false)}
              /> */}

            </div>
          </div>

        </div>

        <img className="downarrow" src={Arrow} alt="arrow" />
        <div className="swapto ml-4 mr-4">
          <div>
            <p>To</p>
            <input
              className="form-input"
              type="number"
              placeholder="0.0"
              disabled
            ></input>
          </div>
          <div>
            <button className='swaptobtn' onClick={() => setModalShow(true)}> <span>Select a token <img src={Down} alt="downarrow" /></span> </button>
          </div>
        </div>
        <div className="swapbtn">
          <button className="swapconfirmbtn mt-4">Buy Cobalt Tokens </button>
        </div>
      </form>
    </div>
  )
}

export default Swap;