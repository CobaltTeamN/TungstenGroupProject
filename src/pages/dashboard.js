import React, { useState, useContext } from 'react';
import axios from 'axios';
import { StyledCard, Container} from '../components/styled/Dashboard';
import {Button} from 'react-bootstrap';
import Logo from '../icons/MovingLogo.mp4'
import './dashboard.css'
import { GlobalState } from "../GlobalState.js";

export default function DashBoardHome() {
  const state = useContext(GlobalState)
  
  const [cryptolist ,setCryptoList] = useState([]);
  
  const getCrypto = async () => {
    const url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
    try {
      const res = await axios.get(url)
      setCryptoList(res.data)
    } catch (error) {
      console.error(error);
    }
  }
  if (!state) {
    console.log(state + cryptolist + getCrypto) 
  }
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
    </Container>
  );
}
