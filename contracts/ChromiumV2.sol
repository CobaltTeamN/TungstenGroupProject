// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import './interfaces/IUniswap.sol';

contract ChromiumV2 is Ownable {
    using UniversalERC20 for IERC20;

    struct TokenInfo {
        bool fromTokenActive;
        bool destTokenActive;
    }

    // used to keep track of tokens in contract
    mapping(address => uint) public tokenLiquidity;
    mapping(uint => uint) public cbltLiquidity;
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
     * Pools that i created on rinkeby uniswap
     * eth (0xc778417E063141139Fce010982780140Aa0cD5Ab) / cblt (0xd39E2AD90DbEFaE11da028B19890d0eE45713780)
     * cblt (0xd39E2AD90DbEFaE11da028B19890d0eE45713780) / ham (0x1e22E4F74DB4BC6745486Ee3D7ADF2584980DCb2)
     * if you want to test the call, those pairs will work on rinkeby network
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
    returns (uint)
    {
        IERC20(path[0]).universalTransferFromSenderToThis(amount);
        tokenLiquidity[path[0]] = SafeMath.add(tokenLiquidity[path[0]], amount);
        uint[] memory amounts = getExchangeRate(amount, path);

        if (IERC20(path[0]) == ETH_ADDRESS) {
            require(msg.value != 0, "Chromium:: msg.value can not equal 0");
            require(tokenLiquidity[path[1]] >= amounts[1], "Not enough tokens in Treasury.");

            IERC20(path[1]).universalTransfer(msg.sender, amounts[1]);
            tokenLiquidity[path[1]] = SafeMath.sub(tokenLiquidity[path[1]], amounts[1]);
            emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
            return amounts[1];
        } else {
            require(tokenLiquidity[path[1]] >= amounts[1], "Chromium:: Not enough tokens in Treasury.");

            IERC20(path[1]).universalTransfer(msg.sender, amounts[1]);
            emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
            return amounts[1];
        }

    }

    function swapCblt(
        address[] calldata path,
        uint256 amount
    )
    external
    payable
    returns (uint)
    {
        require(path[0] == address(cbltToken), "Chromium:: fromToken needs to be cbltToken.");
        cbltToken.universalTransferFromSenderToThis(amount);
        uint temp = getCbltPool(amount);
        cbltLiquidity[temp] = SafeMath.add(cbltLiquidity[temp], amount);
        uint[] memory amounts = getExchangeRate(amount, path);

        require(tokenLiquidity[path[1]] >= amounts[1], "Not enough tokens in treasury.");

        IERC20(path[1]).universalTransfer(msg.sender, amounts[1]);
        tokenLiquidity[path[1]] = SafeMath.sub(tokenLiquidity[path[1]], amounts[1]);
        emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
        return amounts[1];
    }

    function swapForCblt(
        address[] calldata path,
        uint256 amount
    )
    external
    payable
    returns (uint)
    {
        require(path[1] == address(cbltToken), "Chromium:: destToken needs to be cbltToken.");
        IERC20(path[0]).universalTransferFromSenderToThis(amount);
        tokenLiquidity[path[0]] = SafeMath.add(tokenLiquidity[path[0]], amount);
        uint[] memory amounts = getExchangeRate(amount, path);
        uint temp = getCbltPool(amounts[1]);

        if (IERC20(path[0]) == ETH_ADDRESS) {
            require(msg.value != 0, "Chromium:: msg.value can not equal 0");
            require(cbltLiquidity[temp] >= amounts[1], "Not enough cblt tokens in pool for 1000 and up in Treasury.");

            cbltLiquidity[temp] = SafeMath.sub(cbltLiquidity[temp], amounts[1]);
            cbltToken.universalTransfer(msg.sender, amounts[1]);
            emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
            return amounts[1];
        } else {
            require(cbltLiquidity[temp] >= amounts[1], "Not enough cblt tokens in pool for 1000 and down in Treasury.");

            cbltLiquidity[temp] = SafeMath.sub(cbltLiquidity[temp], amounts[1]);
            cbltToken.universalTransfer(msg.sender, amounts[1]);
            emit ChromiumTrade(msg.sender, path[0], path[1], amount, amounts[1]);
            return amounts[1];
        }
    }

    function addCbltToPool(
        uint _poolNumber,
        uint _amount
    )
    external
    onlyOwner
    {
        cbltToken.universalTransferFromSenderToThis(_amount);
        cbltLiquidity[_poolNumber] = SafeMath.add(cbltLiquidity[_poolNumber], _amount);
    }

    function retrieveTokens(
        IERC20 _token,
        uint amount
    )
    external
    onlyOwner
    {
        require(amount <= tokenLiquidity[address(_token)], "Chromium:: not enough tokens in exchange.");
        _token.universalTransfer(msg.sender, amount);
    }

    function getCbltPool(
        uint amount
    )
    internal
    pure
    returns (uint)
    {
        if (amount >= 1000000000000000000000) {
            return 1;
        } else {
            return 2;
        }
    }

    // fallback function
    receive() external payable {}
}
