import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { SpaceAroundRow, StyledCard, CobaltContainer, StyledCardHeightFit,
  Row, Col, Container, CobaltCard} from '../components/styled/Dashboard';
import Activity from '../components/activity';
import Wallet from '../components/wallet';
import './dashboard.css'

export default function DashBoardHome() {

  const [cryptos, setCryptoList] = useState([]);
  const [crypto, setCrypto] = useState('');

  const formatter = new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  const getCrypto = async () => {
    const url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
    try {
      const res = await axios.get(url)
      setCryptoList(res.data)
    } catch (error) {
      console.error(error);
    }
  }
  useEffect(() => {
    getCrypto()
  }, [])

  function handleChange(event) {
    setCrypto(event.target.value);
    console.log(crypto)
  }

  return (
    <Container>
      {/* Stacking Snippet */}
      <SpaceAroundRow>
       <StyledCard elevation={3}>
        <Col>
          <h3>Staking</h3>
        </Col>
        <Col>
          <p>ROI</p>
        </Col>
        <Col>
          <p>Wallet</p>
        </Col>
        <button></button>
      </StyledCard>
      {/* CBLT Snippet */}
      <StyledCard elevation={3}>
        <Col>
          <h3>CBLT</h3>
        </Col>
        <Col>
          <p>Current Position</p>
        </Col>
        <Col>
          <p>Increase Position</p>
        </Col>
        <button></button>
      </StyledCard>
      {/* CBLT Snippet */}
      <StyledCard elevation={3}>
        <Col>
          <h3>CBLT</h3>
        </Col>
        <Col>
          <p>Total CBLT Supply</p>
        </Col>
        <Col>
          <p>Total CBLT Burned</p>
        </Col>
      </StyledCard>
    </SpaceAroundRow>
    <div className="card">
    <div className="box">
        <div className="img">
            <img src="https://www.planwallpaper.com/static/images/cool-wallpaper-5_G6Qe1wU.jpg"/>
        </div>
        <h2>Account Name<br/><span>Crypto</span></h2>
        <p> Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
                tempor incididunt ut labore et.</p>
    </div>
</div>
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
