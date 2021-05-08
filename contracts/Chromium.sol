// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * getExpectedReturnWithGas is a method on the 1inch protocol that is free to call and will return
 * a distribution array. each element in array shows an exchange and represents a fraction of trading volume.
 * it will also return the amount the minimum amount tokens that will be received by the caller based on the amount
 * that they are selling. it also returns the amount of gas that is being used.
 *
 * I removed the oracle because i figured we can use the _minReturn from getExpectedReturnWithGas as the conversion
 * rate for the two tokens instead of having our own oracle.
 *
 * the exchangeTokens method will first check if the tokens are allowed in our contract and if we have enough
 * tokens in the contract to make the exchange. if we do then the exchange will happen here. if we dont, then
 * the 1inch swap protocol will be called to complete the exchange
<<<<<<< HEAD
 */

import "./interfaces/UniversalERC20.sol";
import "./interfaces/Ownable.sol";
import "./interfaces/IOneSplit.sol";
import "./ExchangeOracle.sol";
import "./Bank.sol";

contract Chromium is Ownable {
    using UniversalERC20 for IERC20;

    mapping(IERC20 => uint256) public liquidityAmount;
    uint256 amountOfCblt;

    address oracleAddress;

    Bank treasury;
    ExchangeOracle oracle;
    IERC20 cblt_token;

    IERC20 private constant ZERO_ADDRESS =
        IERC20(0x0000000000000000000000000000000000000000); // eth address substitute
    IERC20 private constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE); // eth address substitute
    IOneSplit private constant oneSplitImpl =
        IOneSplit(0xc3037b2A1a9E9268025FF6d45Fe7095436446D52); // sets 1inch protocol
=======
*/

import "./interfaces/UniversalERC20.sol";
import './interfaces/Ownable.sol';
import "./interfaces/IOneSplit.sol";
import './ExchangeOracle.sol';

contract Chromium is Ownable{
    using UniversalERC20 for IERC20;

    mapping(IERC20 => uint) public liquidityAmount;
    uint public amountOfCblt;
    address oracleAddress;

    ExchangeOracle oracle;
    IERC20 cblt_token;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000); // eth address substitute
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE); // eth address substitute
    IOneSplit private constant oneSplitImpl = IOneSplit(0xc3037b2A1a9E9268025FF6d45Fe7095436446D52); // sets 1inch protocol
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646

    event depositToken(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event tokensExchanged(
        address indexed _sendingToken,
        uint256 _amountSent,
        address indexed _receivedToken,
        uint256 _amountRecieved
    );

    /**
     * pass in the oracle contract so that it can pull info from it
     */
<<<<<<< HEAD
    constructor(
        address _oracle,
        address payable _treasury,
        address _cbltAddress
    ) {
        oracle = ExchangeOracle(_oracle);
        treasury = Bank(_treasury);
        oracleAddress = _oracle;
        cblt_token = IERC20(_cbltAddress);
    }

    /** this sets the treasury, and oracle */

    function setTreasury(address payable _treasury) public onlyOwner {
        treasury = Bank(_treasury);
    }

=======
    constructor(address _oracle, address _cbltToken) {
        oracle = ExchangeOracle(_oracle);
        oracleAddress = _oracle;
        cblt_token = IERC20(_cbltToken);
    }

    /** this sets the treasury, and oracle */
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    function setOracle(address _oracle) public onlyOwner {
        oracle = ExchangeOracle(_oracle);
        oracleAddress = _oracle;
    }

    function setCbltToken(address _cblt) public onlyOwner {
        cblt_token = IERC20(_cblt);
    }

<<<<<<< HEAD
    /**
     * @dev this function should be called to deposit the cblt tokens that are initial sent
     * to chromium to use
     */
    function depositCbltToTreasury(IERC20 _cblt, uint256 _amount)
        external
        payable
    {
        _cblt.universalTransferFromSenderToThis(_amount);
        amountOfCblt = SafeMath.add(amountOfCblt, _amount);

        // treasury.depositTokens{value: msg.value}(address(_cblt), _amount);
    }

=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    /************ chromium functions ************/
    /**
     * @dev this function will get the exchagne rate for the token being exchanged for cblt token
     * it will call on the oracle to make the calculation. the returnAmount is going to be a factor
     * of three larger than the actual amount which means the returnAmount will need to be divided by
     * 1000 to get the correct amount that will be swapped
<<<<<<< HEAD
     */
    function getCbltExchangeRate(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) public view returns (uint256 returnAmount) {
        require(_checkTokensAllowed(fromToken, destToken));
        (uint256 sellTokenValue, uint256 buyTokenValue) =
            oracle.priceOfPair(address(fromToken), address(destToken));
        returnAmount = SafeMath.mul(
            amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );
=======
    */
    function getCbltExchangeRate(
        IERC20 fromToken,
        IERC20 cbltToken,
        uint256 amount
    )
    public
    view
    returns(uint returnAmount)
    {
        require(_checkTokensAllowed(cbltToken));
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.priceOfPair(fromToken, cbltToken);
        returnAmount = SafeMath.mul(amount,
            SafeMath.findRate(sellTokenValue, buyTokenValue)
        );

>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    }

    /**
     * @dev this function will swap cblt tokens for tokens that are allowed in the bank
     * it calls on a function inside of the bank to do the exchange since no tokens are going
     * to be held in the exchange
<<<<<<< HEAD
     */
    function swapForCblt(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn
    ) external payable {
        require(_checkTokensAllowed(fromToken, destToken));
        require(amountOfCblt >= minReturn, "Not enough tokens in Treasury.");

        fromToken.universalTransferFromSenderToThis(amount);
        liquidityAmount[fromToken] = SafeMath.add(
            liquidityAmount[fromToken],
            amount
        );

        fromToken.universalApprove(address(treasury), amount);
        treasury.withdrawCbltForExchange{value: msg.value}(
            fromToken,
            destToken,
            msg.sender,
            amount,
            minReturn
        );

        amountOfCblt = SafeMath.sub(amountOfCblt, minReturn);
    }

    /************ 1inch Protocol functions ************/
    /**
     * @dev Calculate expected returning amount of `destToken`
     * @param fromToken (IERC20) Address of token or `address(0)` for Ether
     * @param destToken (IERC20) Address of token or `address(0)` for Ether
     * @param amount (uint256) Amount for `fromToken`
     * @param parts (uint256) Number of pieces source volume could be splitted,
     * works like granularity, higly affects gas usage. Should be called offchain,
     * but could be called onchain if user swaps not his own funds, but this is still considered as not safe.
     * @param flags (uint256) Flags for enabling and disabling some features, default 0
     */
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        return
            oneSplitImpl.getExpectedReturn(
                fromToken,
                destToken,
                amount,
                parts,
                flags
            );
=======
    */
    function swapForCblt(
        IERC20 fromToken,
        IERC20 cbltToken,
        uint256 amount,
        uint256 minReturn
    )
    external
    payable
    {
        require(_checkTokensAllowed(cbltToken));
        require(cbltToken.universalBalanceOf(address(this)) >= minReturn, "Not enough tokens in Treasury.");

        fromToken.universalTransferFromSenderToThis(amount);

        cbltToken.universalTransfer(msg.sender, minReturn);

>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    }

    /**
     * @dev Swap `amount` of `fromToken` to 'destToken`
     * @param fromToken (IERC20) Address of token or `address(0)` for Ether
     * @param destToken (IERC20) Address of token or `address(0)` for Ether
     * @param amount (uint256) Amount for `fromToken`
     * @param minReturn (uint256) Minimum expected return, returned by getExpectedReturn
     * @param distribution (uint256[]) Array of weights for volume distribution returned by `getExpectedReturn`
     * @param flags (uint256) Flags for enabling and disabling some features, default 0
<<<<<<< HEAD
     */
=======
    */
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
<<<<<<< HEAD
    ) external payable returns (uint256 returnAmount) {
        // makes sure tokens aren't the same and amount is greater than 0
        require(fromToken != destToken && amount > 0, "Unable to swap");
        // makes sure msg.value is only being used for eth
        require(
            (msg.value != 0) == fromToken.isETH(),
            "msg.value can only be used for eth"
        );

        uint256 fromTokenBalanceBefore =
            SafeMath.sub(
                fromToken.universalBalanceOf(address(this)),
                msg.value
            );
        uint256 destTokenBalanceBefore =
            destToken.universalBalanceOf(address(this));
=======
    ) external payable returns(uint returnAmount){
        // makes sure tokens aren't the same and amount is greater than 0
        require(fromToken != destToken && amount > 0, "Unable to swap");
        // makes sure msg.value is only being used for eth
        require((msg.value != 0) == fromToken.isETH(), "msg.value can only be used for eth");

        uint fromTokenBalanceBefore = SafeMath.sub(fromToken.universalBalanceOf(address(this)), msg.value);
        uint destTokenBalanceBefore = destToken.universalBalanceOf(address(this));
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646

        fromToken.universalTransferFromSenderToThis(amount);
        fromToken.universalApprove(address(oneSplitImpl), amount);

<<<<<<< HEAD
        oneSplitImpl.swap{value: msg.value}(
=======
        oneSplitImpl.swap{value:msg.value}(
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
            fromToken,
            destToken,
            amount,
            minReturn,
            distribution,
            flags
        );

<<<<<<< HEAD
        uint256 fromTokenBalanceAfter =
            fromToken.universalBalanceOf(address(this));
        uint256 destTokenBalanceAfter =
            destToken.universalBalanceOf(address(this));
        returnAmount = SafeMath.sub(
            destTokenBalanceAfter,
            destTokenBalanceBefore
        );

        require(
            returnAmount >= minReturn,
            "actual return amount is less than min return amount"
        );
        destToken.universalTransfer(msg.sender, returnAmount);

        if (fromTokenBalanceAfter > fromTokenBalanceBefore) {
            fromToken.universalTransfer(
                msg.sender,
                SafeMath.sub(fromTokenBalanceAfter, fromTokenBalanceBefore)
            );
        }

        emit tokensExchanged(
            address(fromToken),
            amount,
            address(destToken),
            minReturn
        );
=======
        uint fromTokenBalanceAfter = fromToken.universalBalanceOf(address(this));
        uint destTokenBalanceAfter = destToken.universalBalanceOf(address(this));
        returnAmount = SafeMath.sub(destTokenBalanceAfter, destTokenBalanceBefore);

        require(returnAmount >= minReturn, "actual return amount is less than min return amount");
        destToken.universalTransfer(msg.sender, returnAmount);

        if (fromTokenBalanceAfter > fromTokenBalanceBefore) {
            fromToken.universalTransfer(msg.sender, SafeMath.sub(fromTokenBalanceAfter, fromTokenBalanceBefore));
        }

        emit tokensExchanged(address(fromToken), amount, address(destToken), minReturn);
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    }

    /**
     * @dev this function will check to see if the both tokens are correct when wanting
     * to make the exchange with chromium
<<<<<<< HEAD
     */
    function _checkTokensAllowed(IERC20 fromToken, IERC20 destToken)
        internal
        view
        returns (bool)
    {
        if (
            treasury.isTokenAllowed(address(fromToken)) &&
            destToken == cblt_token
        ) {
=======
    */
    function _checkTokensAllowed(IERC20 cbltToken)
    internal
    view
    returns(bool)
    {
        if ( cbltToken == cblt_token) {
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
            return true;
        } else {
            return false;
        }
    }

    function testCall() public view returns (uint256 value) {
<<<<<<< HEAD
        (uint256 sellTokenValue, uint256 buyTokenValue) =
            oracle.testConnection();
        value = sellTokenValue + buyTokenValue;
=======
        (uint256 sellTokenValue, uint256 buyTokenValue) = oracle.testConnection();
        value = sellTokenValue + buyTokenValue;

>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    }

    // fallback function
    receive() external payable {}
}
