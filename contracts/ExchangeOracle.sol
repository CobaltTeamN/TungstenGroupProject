// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";

contract ExchangeOracle is Ownable {
    uint256 USDpriceETH = 400000;
    mapping(address => Token) tokenData; // Token information accessed by token address

    // Struct saving token data
    struct Token {
        uint256 value;
        bool active;
    }

    modifier activeToken(address _tokenAddress) {
        require(
            tokenData[_tokenAddress].active == true,
            "Token not currently supported."
        );
        _;
    }

    // Events
    event deletedToken(address token);

    event tokenUpdatedData(uint256 _value);

    constructor() {
        tokenData[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = Token(
            1000000000000000000,
            true
        );
        // rinkeby weth address to work with uniswap
        tokenData[0xc778417E063141139Fce010982780140Aa0cD5Ab] = Token(
            1000000000000000000,
            true
        );
        tokenData[0x433C6E3D2def6E1fb414cf9448724EFB0399b698] = Token(
            2000000000000,
            true
        );
    }

    function updateToken(
        address _tokenAddress,
        uint256 _value,
        bool _status
    ) public {
        // Update token data
        tokenData[_tokenAddress] = Token(_value, _status);
        // Emit event with new token information
        emit tokenUpdatedData(_value);
    }

    function priceOfPair(address _sellTokenAddress, address _buyTokenAddress)
        public
        view
        returns (
            uint256 sellTokenPrice,
            uint256 buyTokenPrice,
            bool success
        )
    {
        if (tokenData[_sellTokenAddress].active) {
            return (
                tokenData[_sellTokenAddress].value,
                tokenData[_buyTokenAddress].value,
                true
            );
        } else {
            return (0, 0, false);
        }
    }

    function priceOfETHandCBLT(address _cbltToken)
        public
        view
        returns (uint256, uint256)
    {
        return (tokenData[_cbltToken].value, USDpriceETH);
    }

    function priceOfETH() public view returns (uint256) {
        return (USDpriceETH);
    }

    function priceOfToken(address _tokenAddress)
        public
        view
        activeToken(_tokenAddress)
        returns (uint256)
    {
        return (tokenData[_tokenAddress].value);
    }

    function testConnection()
        public
        pure
        returns (uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        return (1, 1);
    }
}
