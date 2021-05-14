import React, { useState, useEffect, useContext } from 'react';
import axios from 'axios';
import { StyledCard, Container,
  //  CobaltCard, CobaltContainer, StyledCardHeightFit, Row, Col
 } from '../components/styled/Dashboard';
// import Activity from '../components/activity';
// import Wallet from '../components/wallet';
import {Button} from 'react-bootstrap';
import Logo from '../icons/MovingLogo.mp4'
import './dashboard.css'
import { GlobalState } from "../GlobalState.js";

export default function DashBoardHome() {
  const state = useContext(GlobalState)
  console.log(state)
  // const [isLoggedIn] = state.web3API.isLoggedIn
  // const loadWeb3 = state.web3API.loadWeb3
  const [cryptolist ,setCryptoList] = useState([]);
  // const [crypto, setCrypto] = useState('');

  // const formatter = new Intl.NumberFormat('en-US', {
  //   minimumFractionDigits: 2,
  //   maximumFractionDigits: 2,
  // });

  const getCrypto = async () => {
    const url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
    try {
      const res = await axios.get(url)
      setCryptoList(res.data)
    } catch (error) {
      console.error(error);
    }
  }
  // useEffect(() => {
  //   console.log(state)
  //   getCrypto()
  // }, [])

  // function handleChange(event) {
  //   setCrypto(event.target.value);
  //   console.log(crypto)
  // }

  return (
    <Container>
      <StyledCard className="dashboard-main" elevation={3}>
        <div className="spacearound">
          <Button variant="outline-secondary">Scoring Token</Button>
          <Button variant="outline-secondary">Connect Wallet</Button>
        </div>
        <h2 className="dashboard-title">Cobalt Lend</h2>
        <div className="main-dashboard">
          <div className="left-dashboard">
            <Button variant="light">Treasury Balance</Button>
            <Button variant="light">Your Staking Rewards</Button>
            <Button variant="light">Current Oustanding Loans</Button>
            <Button variant="light">Loan Proposals Up for Vote</Button>
          </div>
          <div className="middle-dashboard">
            <video className="logo-video" autoPlay="autoplay" muted="muted" loop="loop">
              <source src={Logo} type="video/mp4"/>
            </video>
            <Button variant="light">Current Cobalt Price</Button>
          </div>
          <div className="right-dashboard">
            <Button variant="light">Loan Status</Button>
            <Button variant="light">Outstanding Loan Balance</Button>
          </div>
        </div>
      </StyledCard>

      {/* <CobaltContainer>
        <CobaltCard elevation={3}>
          <img
            src="CobaltLogo.jpg"
            style={{ width: '50%', padding: '5%' }}
            alt="cobalt logo"
          />
          <form>
            <label>
              Please add token to your wallet
              <select onChange={handleChange}>
                <option>
                  Please add token to your wallet
                </option>
                {cryptos.map(crypto => {
                  return (<>
                    <option key={crypto.name} value={crypto.name}>
                      <img src={crypto.image} alt={crypto.name} width="40px" />
                      {crypto.name}
                    </option>
                  </>)
                })}
              </select>
            </label>
          </form>
          <h3>CBLT</h3>
          <p>Current Price</p>
          <SpaceAroundRow style={{ width: '100%' }}>
            <span> .5 BTC</span>
            <span> 2 ETH</span>
            <span>100,000 USD</span>
          </SpaceAroundRow>
        </CobaltCard>
        <CobaltCard elevation={3} className="ml-5">
        <Activity />
        </CobaltCard>
        <SpaceAroundRow className="ml-5">
          <Col>
          <StyledCardHeightFit className="mb-5" elevation={3}>
          <Row>
        <Col>
        <Wallet/>   
        </Col>
        </Row>
        </StyledCardHeightFit>
        <StyledCardHeightFit className="mb-5" elevation={3}>
          <Row>
        <Col>
        <Wallet/>   
        </Col>
        </Row>
        </StyledCardHeightFit>
        <StyledCardHeightFit className="mb-5" elevation={3}>
          <Row>
        <Col>
        <Wallet/>   
        </Col>
        </Row>
          </StyledCardHeightFit>
          </Col>
        </SpaceAroundRow>
      </CobaltContainer> */}
    </Container>
  );
}
