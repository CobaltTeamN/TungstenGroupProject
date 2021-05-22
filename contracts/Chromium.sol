// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './ExchangeOracle.sol';
import './interfaces/IUniswap.sol';

contract Chromium is Ownable {
    using UniversalERC20 for IERC20;

    // used to keep track of tokens in contract
    mapping(IERC20 => uint) public liquidityAmount;

    // weth address that i am using for eth
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    // IERC20 private constant cbltToken = IERC20(0x433C6E3D2def6E1fb414cf9448724EFB0399b698);

    // initializing objects
    ExchangeOracle oracle;
    IERC20 cbltToken;

    mapping(IERC20 => uint) feeTotal;

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
     * will need to be divided by 100000 by the frontend to get the correct amount that will be swapped
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
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(destToken));
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
        fromToken.universalTransferFrom(msg.sender, address(this), amount);

        if (fromToken == ETH_ADDRESS) {
            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                2843
            );
            amount = SafeMath.sub(amount, usdFee);

            (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));
            uint returnAmount = SafeMath.mul(amount,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            returnAmount = SafeMath.div(returnAmount, 1000000);
            require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

            cbltToken.universalTransfer(msg.sender, returnAmount);
            feeTotal[fromToken] = SafeMath.add(feeTotal[fromToken], usdFee);
            liquidityAmount[fromToken] = SafeMath.add(liquidityAmount[fromToken], SafeMath.add(amount, usdFee));
            emit ChromiumTrade(msg.sender, address(fromToken), amount, returnAmount);
        } else {

            (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(fromToken), address(cbltToken));

            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2843, sellTokenValue)
            );
            amount = SafeMath.sub(amount, usdFee);

            uint returnAmount = SafeMath.mul(amount,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            returnAmount = SafeMath.div(returnAmount, 1000000);
            require(cbltToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

            cbltToken.universalTransfer(msg.sender, returnAmount);
            feeTotal[fromToken] = SafeMath.add(feeTotal[fromToken], usdFee);
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
            (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(cbltToken), address(destToken));
            uint returnAmount = SafeMath.mul(amountOfCblt,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2843, buyTokenValue)
            );

            returnAmount = SafeMath.sub(returnAmount, usdFee);
            returnAmount = SafeMath.div(returnAmount, 1000000);
            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");

            destToken.universalTransfer(msg.sender, returnAmount);
            emit ChromiumTrade(msg.sender, address(cbltToken), amountOfCblt, returnAmount);
        } else {

            (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(address(cbltToken), address(destToken));
            uint returnAmount = SafeMath.mul(amountOfCblt,
                SafeMath.findRate(sellTokenValue, buyTokenValue)
            );

            uint256 usdFee =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(1000000000000000000, 2843)
            );

            returnAmount = SafeMath.sub(returnAmount, usdFee);
            returnAmount = SafeMath.div(returnAmount, 1000000);

            require(destToken.universalBalanceOf(address(this)) >= returnAmount, "Not enough tokens in Treasury.");
            destToken.universalTransfer(msg.sender, returnAmount);

            emit ChromiumTrade(msg.sender, address(cbltToken), amountOfCblt, returnAmount);
        }
    }

    // fallback function
    receive() external payable {}
}
