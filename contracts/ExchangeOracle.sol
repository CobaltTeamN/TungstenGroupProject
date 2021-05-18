// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";

contract ExchangeOracle is Ownable {
    mapping(address => Token) tokenData; // Token information accessed by token address

    // Struct saving token data
    struct Token {
        string name;
        string symbol;
        string img;
        uint256 value;
        bool active;
    }

    // Events
    event deletedToken(address token);

    event tokenUpdatedData(
        string _name,
        string _symbol,
        string _img,
        uint256 _value
    );

    constructor() {
        tokenData[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = Token(
            "Ethereum",
            "ETH",
            "url",
            40000000000000,
            true
        );
    }

    function updateToken(
        address _tokenAddress,
        string memory _name,
        string memory _symbol,
        string memory _img,
        uint256 _value,
        bool _active
    ) public {
        // Update token data
        tokenData[_tokenAddress] = Token(_name, _symbol, _img, _value, _active);
        // Emit event with new token information
        emit tokenUpdatedData(_name, _symbol, _img, _value);
    }

    function priceOfPair(address _sellTokenAddress, address _buyTokenAddress)
        public
        view
        returns (uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        return (
            tokenData[_sellTokenAddress].value,
            tokenData[_buyTokenAddress].value
        );
    }

    function testConnection()
        public
        pure
        returns (uint256 sellTokenPrice, uint256 buyTokenPrice)
    {
        return (2, 3);
    }

    function getValue(address _tokenAddress) public view returns (uint256) {
        return tokenData[_tokenAddress].value;
    }
}
