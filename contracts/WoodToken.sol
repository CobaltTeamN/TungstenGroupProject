// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract WoodToken {
    string public constant name = "WoodToken";
    string public constant symbol = "WrJ";
    uint8 public constant decimals = 18;
    uint256 public _totalSupply;

    // saving user data on contract storage
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) timestamp; // timestamp of last borrowed time

    // Events
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);

    constructor() {
        _totalSupply = 1000000000;
    }

    // This function will return the total supply subtracting balances of an address
    function totalSupply() public view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function borrow(address _borrower, uint256 _amount) public payable {
        require(_amount <= 100000);
        balances[_borrower] =
            balances[_borrower] +
            (_amount * 1000000000000000000);
        timestamp[_borrower] = block.timestamp;
        emit Borrowed(_borrower, _amount, block.timestamp);
    }

    function donate(address _donator, uint256 _amount) public payable {
        require(balances[_donator] >= _amount * 1000000000000000000);
        balances[_donator] = balances[_donator] - _amount * 1000000000000000000;
    }

    //function will return the balance of the tokenOwner
    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    //Gives the allowance of what is allowed by the tokenOwner and Spender
    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    // the function will tell us if the spender is authorize or approved to use the token
    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        // emit Approval(msg.sender,spender,tokens);
        return true;
    }
}
