// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './ExchangeOracle.sol';

contract Chromium is Ownable {
    using UniversalERC20 for IERC20;

    // used to keep track of tokens in contract
    mapping(IERC20 => uint) public liquidityAmount;

    // eth contract address
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // initializing objects
    ExchangeOracle oracle;
    IERC20 cbltToken;

    // emits when chromium is used
    event ChromiumTrade(address indexed _from, address _fromToken, uint256 _fromAmount, uint _cbltAmount);

    /**
     * pass in the oracle contract so that it can pull info from it
     */
    constructor(address _oracle, address _cblt_token) {
        oracle = ExchangeOracle(_oracle);
        cbltToken = IERC20(_cblt_token);
    }

    /** this sets the treasury, and oracle */
    function setOracle(address _oracle) external onlyOwner {
        oracle = ExchangeOracle(_oracle);
    }

    // sets CBLT token
    function setCbltToken(address _cblt) external onlyOwner {
        cbltToken = IERC20(_cblt);
    }

    /************ chromium functions ************/
    /*
     * @dev this function will get the exchagne rate for the token being exchanged for cblt token
     * it will call on the oracle to make the calculation. the returnAmount is going to be
     * three times larger than the actual amount (so that we can get decimals) which means the returnAmount
     * will need to be divided by 1000 by the frontend to get the correct amount that will be swapped
    */
    function getCbltExchangeRate(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    )
    public
    view
    returns (uint returnAmount)
    {
        (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(destToken));
        require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
        returnAmount = SafeMath.mul(amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );
    }

    /**
     * @dev this function will swap cblt tokens for tokens that are allowed
    */
    function swapForCblt(
        IERC20 fromToken,
        uint256 amount
    )
    external
    payable
    {
        fromToken.universalTransferFromSenderToThis(amount);

        if (fromToken == ETH_ADDRESS) {
            require(msg.value != 0, "Chromium:: msg.value can not equal 0");
            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                2843
            );
            amount = SafeMath.sub(amount, usdFee);

             (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
             require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
             uint returnAmount = SafeMath.mul(amount,
                 SafeMath.findRate(sellTokenValue, buyTokenValue)
             );

            returnAmount = SafeMath.div(returnAmount, (10**18));
            require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

            cbltToken.universalTransfer(msg.sender, returnAmount);
            liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], SafeMath.add(amount, usdFee));
            emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
        } else {

            (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
            require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2843, sellTokenValue)
            );
            amount = SafeMath.sub(amount, usdFee);

            uint returnAmount = SafeMath.mul(amount,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            returnAmount = SafeMath.div(returnAmount, (10**18));
            require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Chromium:: Not enough tokens in Treasury.");

            cbltToken.universalTransfer(msg.sender, returnAmount);
            liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], SafeMath.add(amount, usdFee));
            emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
        }

    }

    function swapCbltForToken(
        IERC20 destToken,
        uint amountOfCblt
    )
    external
    payable
    {
        cbltToken.universalTransferFrom(msg.sender, address(this), amountOfCblt);

        if (destToken == ETH_ADDRESS) {
            (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(cbltToken), address(destToken));
            require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
            uint returnAmount = SafeMath.mul(amountOfCblt,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2843, buyTokenValue)
            );

            returnAmount = SafeMath.sub(returnAmount, usdFee);
            returnAmount = SafeMath.div(returnAmount, (10**18));
            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Chromium:: Not enough tokens in Treasury.");

            destToken.universalTransfer(msg.sender, returnAmount);
            emit ChromiumTrade(msg.sender, address(cbltToken), amountOfCblt, returnAmount);
        } else {

            (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(cbltToken), address(destToken));
            require(possibleTrade, "One of the tokens is not on the trading list.");
            uint returnAmount = SafeMath.mul(amountOfCblt,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(1000000000000000000, 2843)
            );

            returnAmount = SafeMath.sub(returnAmount, usdFee);
            returnAmount = SafeMath.div(returnAmount, (10**18));

            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Chromium:: Not enough tokens in Treasury.");
            destToken.universalTransfer(msg.sender, returnAmount);

            emit ChromiumTrade(msg.sender, address(cbltToken), amountOfCblt, returnAmount);
        }
    }

    function swapTokenForToken(
        IERC20 fromToken,
        IERC20 destToken,
        uint amount
    )
    external
    payable
    {
        fromToken.universalTransferFromSenderToThis(amount);

        if (fromToken == ETH_ADDRESS) {
            require(msg.value != 0, "Chromium:: msg.value can not equal 0");
            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                2843
            );
            amount = SafeMath.sub(amount, usdFee);

            (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(destToken));
            require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
            uint returnAmount = SafeMath.mul(amount,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            returnAmount = SafeMath.div(returnAmount, (10**18));
            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

            destToken.universalTransfer(msg.sender, returnAmount);
            liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], amount);
            emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
        } else {

            (bool possibleTrade, uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(destToken));
            require(possibleTrade, "Chromium:: One of the tokens is not on the trading list.");
            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2843, sellTokenValue)
            );
            amount = SafeMath.sub(amount, usdFee);

            uint returnAmount = SafeMath.mul(amount,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            returnAmount = SafeMath.div(returnAmount, (10**18));
            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Chromium:: Not enough tokens in Treasury.");

            destToken.universalTransfer(msg.sender, returnAmount);
            liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], SafeMath.add(amount, usdFee));
            emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
        }

    }

    // fallback function
    receive() external payable {}
}
