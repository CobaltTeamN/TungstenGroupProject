// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './interfaces/IUniswap.sol';

contract Chromium is Ownable {
    using UniversalERC20 for IERC20;

    struct TokenInfo {
        bool fromTokenActive;
        bool destTokenActive;
    }

    // used to keep track of tokens in contract
    mapping(address => TokenInfo) tokenApproval;

    // eth contract address
    IERC20 private constant ETH_ADDRESS = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    IUniswap private constant uniswap = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    // initializing objects
    IERC20 cbltToken;

    // emits when chromium is used
    event ChromiumTrade(address indexed _from, address _fromToken, address _destToken, uint256 _fromAmount, uint _cbltAmount);

    /**
     * pass in the oracle contract so that it can pull info from it
     */
    constructor(address _cbltToken) {
        cbltToken = IERC20(_cbltToken);
        tokenApproval[_cbltToken] = TokenInfo(true, true);
        tokenApproval[address(ETH_ADDRESS)] = TokenInfo(true, true);
    }

    // sets CBLT token
    function setCbltToken(address _cblt) external onlyOwner {
        cbltToken = IERC20(_cblt);
    }

    function addTokenApproval(
        address _token,
        bool _fromActive,
        bool _destActive
    )
    external
    onlyOwner
    {
        tokenApproval[_token] = TokenInfo(_fromActive, _destActive);
    }

    /************ chromium functions ************/
    /*
     * @dev this function will get the exchagne rate for the token being exchanged for cblt token
     * it will call on the oracle to make the calculation. the returnAmount is going to be
     * three times larger than the actual amount (so that we can get decimals) which means the returnAmount
     * will need to be divided by 1000 by the frontend to get the correct amount that will be swapped
    */
    function getExchangeRate(
        uint256 amountIn,
        address[] calldata path
    )
    public
    view
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "Chromium:: incorrect path length");
        require(tokenApproval[path[0]].fromTokenActive == true &&
            tokenApproval[path[1]].destTokenActive == true,
            "Chromium:: One token is not active for trade"
        );
        amounts = uniswap.getAmountsOut(amountIn, path);
    }

    /**
     * @dev this function will swap cblt tokens for tokens that are allowed
    */
    function swapTokens(
        address[] calldata path,
        uint256 amount
    )
    external
    payable
    returns(uint)
    {
        IERC20(path[0]).universalTransferFromSenderToThis(amount);
        uint[] memory amounts = getExchangeRate(amount, path);

        if (IERC20(path[0]) == ETH_ADDRESS) {
            require(msg.value != 0, "Chromium:: msg.value can not equal 0");
            require(IERC20(path[1]).universalBalanceOf(address(this)) >= amounts[1], "Not enough tokens in Treasury.");

            IERC20(path[1]).universalTransfer(msg.sender, amounts[1]);
            emit ChromiumTrade(msg.sender,path[0], path[1], amount, amounts[1]);
            return amounts[1];
        } else {
            require(IERC20(path[1]).universalBalanceOf(address(this)) >= amounts[1], "Chromium:: Not enough tokens in Treasury.");

            IERC20(path[1]).universalTransfer(msg.sender, amounts[1]);
            emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
            return amounts[1];
        }

    }

    // fallback function
    receive() external payable {}
}
