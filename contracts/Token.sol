// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

contract CHCToken {
    // coin info
    string public constant name = "CHrisCoin";
    string public constant symbol = "CHC";
    uint8 public constant decimals = 18;

    // coin starting params
    address public owner;
    uint256 public total;
    mapping(address => uint256) public borrosewStart;
    mapping(address => bool) public borrowedCooldown;

    // save user balance of token and allowed amount to take out
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) timestamp;

    // Events
    event MinterChanged(address indexed from, address to);
    event Balance(address from, uint256 amount);
    event Mint(address reciever, uint256 amount);
    event Borrowed(address borrower, uint256 amount, uint256 timestamp);

    // on contract deploy set the total supply and assign ownership
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        total = _initialSupply;
    }

    // Information on contract balance
    function totalSupply() public view returns (uint256) {
        return total;
    }

    // Information on user balance
    function balanceOf(address _user) public returns (uint256) {
        emit Balance(_user, balances[_user]);
        return balances[_user];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function transfer(
        address _recipient,
        address _sender,
        uint256 _numTokens
    ) public returns (bool) {
        require(_numTokens <= balances[_sender]);
        balances[_sender] = balances[_sender] - _numTokens; // substract numTokens from user balance
        balances[_recipient] = balances[_recipient] + _numTokens; // add numTokens to reciever address
        return true;
    }

    // owner gives approval for another account to spend a set amount
    // of tokens as allowance
    function approve(
        address _owner,
        address _delegate,
        uint256 _tokenAmount
    ) public returns (bool) {
        allowed[_owner][_delegate] = _tokenAmount;
        return true;
    }

    // user is allowed to make transactions from main account or a delegate of
    function transferFrom(
        address _owner,
        address _sender,
        address _recepient,
        uint256 _tokens
    ) public returns (bool) {
        require(_tokens <= balances[_owner]);
        require(_tokens <= allowed[_owner][_sender]);

        balances[_owner] = balances[_owner] - _tokens;
        allowed[_owner][_sender] = allowed[_owner][_sender] - _tokens;
        balances[_recepient] = balances[_recepient] + _tokens;
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

    // ownership of contract changed
    function passMinterRole(address _mycontractAddress) public returns (bool) {
        require(
            // require caller to me owner
            msg.sender == owner,
            "Error, only owner can change pass minter role"
        );
        owner = _mycontractAddress;

        emit MinterChanged(msg.sender, _mycontractAddress);
        return true;
    }

    // Mint function
    function mint(uint256 _amount) public {
        //check if msg.sender have minter role
        require(
            msg.sender == owner,
            "Error, msg.sender doesn't have minter role"
        );
        total = total + _amount * 1000000000000000000;
    }
}
