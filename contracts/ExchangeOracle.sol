// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";

contract ExchangeOracle is Ownable {
    uint256 USDpriceETH = 400000;
    mapping(address => Token) tokenData; // Token information accessed by token address

    // Struct saving token data
    struct Token {
        uint256 value;
        bool fromActive;
        bool destActive;
    }

    // Events
    event deletedToken(address token);

    event tokenUpdatedData(uint256 _value);

    constructor() {
        tokenData[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = Token(
            1000000000000000000,
            true,
            true
        );
        tokenData[0x433C6E3D2def6E1fb414cf9448724EFB0399b698] = Token(
            2000000000000,
            true,
            true
        );
    }

    function updateToken(
        address _tokenAddress,
        uint256 _value,
        bool _fromActive,
        bool _destActive
    ) public {
        // Update token data
        tokenData[_tokenAddress] = Token(_value, _fromActive, _destActive);
        // Emit event with new token information
        emit tokenUpdatedData(_value);
    }

    function priceOfPair(address _sellTokenAddress, address _buyTokenAddress)
    public
    view
    returns (bool possibleTrade, uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        require(_sellTokenAddress != _buyTokenAddress, "ExchangeOracle:: Tokens can't have the same address");
        if (tokenData[_sellTokenAddress].fromActive == true && tokenData[_buyTokenAddress].destActive == true) {
            return (
            possibleTrade = true,
            tokenData[_sellTokenAddress].value,
            tokenData[_buyTokenAddress].value
            );
        } else {
            return (
            possibleTrade = false,
            0,
            0
            );
        }
    }

    function testConnection()
    public
    pure
    returns (uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        return (1, 1);
    }

    function priceOfPairWithETH(
        address _sellTokenAddress,
        address _buyTokenAddress
    )
    public
    view
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        return (
        tokenData[_sellTokenAddress].value,
        tokenData[_buyTokenAddress].value,
        USDpriceETH
        );
    }

    function priceOfETH() public view returns (uint256) {
        return (USDpriceETH);
    }
}
