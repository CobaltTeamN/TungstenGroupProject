// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./ExchangeOracle.sol";

contract DevPayments {
    
    using UniversalERC20 for IERC20
    
    IERC20 token;
    
    /* 
    Functions:
    - pays devs
        - needs address of all 3 devs
        - proportion total amount of CBLT to % devs receive
        - transfer events 
            - address of dev 
            - # of tokens
            - timestamp
    - allows selling
        - time limit of 1 month inbetween sells
        - limit on total amount u can sell at once
        - make sure only devs and authorized people can take out money
    - add to dev fund
        - send cblt to treasury
    */
    
    event Transfer(
        address _from,
        address _to,
        uint256 _amount
    );
    
    
    mapping(address => uint256) private timeOfLastPayment;
    
    mapping(address => uint256) public tokenReserve;
    
    function getTokenReserve(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return tokenReserve[_tokenAddress];
    }
    
    /*
    function tokenReserveDeposit(uint256 _amount, address _tokenAddress)
        public
        payable
    {
        IERC20(_tokenAddress).universalTransferFromSenderToThis(_amount);
        tokenReserve[_tokenAddress] = SafeMath.add(
            tokenReserve[_tokenAddress],
            _amount
        );
    }
    */
    
    function payDevs(address _dev, uint256 _amount) public canPay(_dev) payable {
        uint256 subtractHelper = SafeMath.sub(getTokenReserve(0x433C6E3D2def6E1fb414cf9448724EFB0399b698), _amount);
        uint256 amountToPay = SafeMath.sub(getTokenReserve(0x433C6E3D2def6E1fb414cf9448724EFB0399b698), subtractHelper);
        IERC20(token).universalTransfer(_dev, _amount);
        timeOfLastPayment[_dev] = block.timestamp;
    }
    
    function getLastPayment(address _dev) public view returns(uint256) {
        return timeOfLastPayment[_dev];
    }
    
    modifier canPay(address _dev) {
        uint256 timeSinceLastPayment = SafeMath.sub(block.timestamp, timeOfLastPayment[_dev]);
        require(timeSinceLastPayment >= 2592000);
        _;
    }
    
    function sell(address _dev, uint256 _amount) public canPay(_dev) payable {
        
        uint256 devAmount = SafeMath.sub(getTokenReserve(0x433C6E3D2def6E1fb414cf9448724EFB0399b698), _amount);
        
        // makes sure is not greater than 33 percent of sell
        require(devAmount != Safemath.mult(devAmount, Safemath.div(33,100));
        
        require( _dev == msg.sender)

    }
    
    
    //Tracks total amount of tokens and sends tokens.
    function Tracker(address _to , uint256 _amount ) public{
        
        //tracks the token amount
        uint256 _totalTracker;
        _totalTracker = Safemath.add(_totalTracker,_amount);
        
        //sends tokens
         IERC20(token).universalTransfer(_to , _totalTracker);
        
    }
}
