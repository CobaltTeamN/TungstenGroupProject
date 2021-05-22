// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

contract Token {
    string public name = "Slick";
    string public symbol = "SLK";
    uint256 public _totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8 public decimals = 18;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);
    event Balance(address from, uint256 amount);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) timestamp; // timestamp of last borrowed time

    constructor() {
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _user) public returns (uint256) {
        emit Balance(_user, balances[_user]);
        return balances[_user];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
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

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
