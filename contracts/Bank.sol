// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract Bank is Ownable {
    uint256 public rate = 10;
    ERC20 token;

    /**
     * @dev mapping used to store all loan information with the key of borrower address
     *  and value of Loan struct with all loan information
     */
    mapping(address => Loan) loanBook;

    constructor(address[] memory addresses, address _CBLT) public {
        for (uint256 i = 0; i < addresses.length; i++) {
            tokensAllowed[addresses[i]] = true;
        }
        token = ERC20(_CBLT);
    }

    /**
     * @dev Struct created so save all loan information
     */
    struct Loan {
        address borrower;
        uint256 dueDate;
        Rational interestRate;
        uint256 paymentPeriod;
        uint256 remainingBalance;
        uint256 minimumPayment;
        uint256 collateralPerPayment;
        bool active;
        bool initialized;
        uint256 timeCreated;
        bool[] votes;
        address[] voters;
    }

    /**
     * @dev Struct used to calculate interest rate
     */
    struct Rational {
        uint256 numerator;
        uint256 denominator;
    }

    /**
     * @dev Events emitted
     */
    event onReceived(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event depositToken(address indexed _from, uint256 _amount);

    /**
     * @dev a list for each token and each user that has deposited some of that
     * token into the bank
     */
    mapping(address => mapping(address => uint256)) public tokenOwnerBalance;
    /**
     * @dev a list of all supported tokens
     */
    mapping(address => bool) public tokensAllowed;
    /**
     * @dev a ledger of the amount of each token in the bank
     */
    mapping(address => uint256) public _tokenSupply;

    /**
     * @dev a ledger of the amount of each token in the bank
     */
    mapping(address => uint256) public etherBalance;

    /**
     * @dev method that will withdraw tokens from the bank if the caller
     * has tokens in the bank
     */

    function withdrawTokens(address _tokenAddress, uint256 _amount) external {
        //Check if token is not supported by bank
        require(tokensAllowed[_tokenAddress] == true, "Token is not supported");
        // Is the user trying to withdraw more tokens than he has in balance?
        require(_amount <= tokenOwnerBalance[_tokenAddress][msg.sender]);
        // Withdraw cannot be equal to zero
        require(_amount != 0, "Withdraw amount cannot be equal to 0");

        token = ERC20(address(_tokenAddress));

        _tokenSupply[_tokenAddress] = SafeMath.sub(
            _tokenSupply[_tokenAddress],
            _amount
        );
        tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.sub(
            tokenOwnerBalance[_tokenAddress][msg.sender],
            _amount
        );

        require(
            token.transfer(msg.sender, _amount) == true,
            "Transfer not complete"
        );
        emit onTransfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev method to withdraw eth from account
     */

    function withdraw(uint256 _amount) external {
        require(_amount <= etherBalance[msg.sender]);
        require(_amount != 0, "Withdraw amount cannot be equal to 0");

        etherBalance[msg.sender] = SafeMath.sub(
            etherBalance[msg.sender],
            _amount
        );

        msg.sender.transfer(_amount);

        emit onTransfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev method to deposit tokens into the bank
     */
    function depositTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        payable
    {
        //Check if token is not supported by bank
        require(tokensAllowed[_tokenAddress] == true, "Token is not supported");
        token = ERC20(address(_tokenAddress));

        _tokenSupply[_tokenAddress] = SafeMath.add(
            _tokenSupply[_tokenAddress],
            _tokenAmount
        );
        tokenOwnerBalance[_tokenAddress][msg.sender] = SafeMath.add(
            tokenOwnerBalance[_tokenAddress][msg.sender],
            _tokenAmount
        );

        require(
            token.transferFrom(msg.sender, address(this), _tokenAmount) == true,
            "Transfer not complete"
        );

        emit depositToken(msg.sender, _tokenAmount);
    }

    /**
     * @dev method to deposit eth into the bank
     */
    function deposit() external payable {
        etherBalance[msg.sender] = SafeMath.add(
            etherBalance[msg.sender],
            msg.value
        );

        emit depositToken(msg.sender, msg.value);
    }

    /**
     * @dev function that will add a token to the list of supported tokens
     */
    function addToken(address _tokenAddress) external onlyOwner returns (bool) {
        tokensAllowed[_tokenAddress] = true;
        return true;
    }

    /**
     * @dev function that will remove token from list of supported tokens
     */
    function removeToken(address _tokenAddress)
        external
        onlyOwner
        returns (bool)
    {
        delete (tokensAllowed[_tokenAddress]);
        return true;
    }

    /**
     * @dev method that will show the total amount of tokens in the bank for
     */
    function totalTokenSupply(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return _tokenSupply[_tokenAddress];
    }

    /**
     * @dev method that will show the balance that the caller has
     * for a certain token
     */
    function balanceOf() public view returns (uint256) {
        return etherBalance[msg.sender];
    }

    function balanceOfToken(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return tokenOwnerBalance[_tokenAddress][msg.sender];
    }

    /**
     * @dev fallback function to receive any eth sent to this contract
     */

    receive() external payable {
        emit onReceived(msg.sender, msg.value);
    }

    // ****************************** Lending **********************************

    /**
     * @dev Recalculates interest and also conducts check and balances
     */
    function newLoan(
        uint256 interestRateNumerator,
        uint256 interestRateDenominator,
        uint256 _paymentPeriod,
        uint256 _minimumPayment,
        uint256 principal,
        uint256 units
    ) public payable {
        // Needs user approve on transfer funds amount
        // token.approve(address(this), _minimumPayment);

        require(loanBook[msg.sender].initialized == false);
        require(
            token.transferFrom(msg.sender, address(this), units * 12) == true,
            "Payment was not approved."
        );
        loanBook[msg.sender] = Loan(
            msg.sender,
            (block.timestamp + _paymentPeriod),
            Rational(interestRateNumerator, interestRateDenominator),
            _paymentPeriod,
            principal,
            _minimumPayment,
            units,
            false,
            true,
            block.timestamp,
            new bool[](0),
            new address[](0)
        );

        //borrow functioning
        require(loanBook[msg.sender].remainingBalance >= 0);
        loanBook[msg.sender] =loanBook[msg.sender] + (balanceOf * borrower);
        timestamp[borrower] = block.timestamp;
        emit balanceOf(borrower, balanceOfToken(_tokenAddress), timestamp);
        

        uint256 x = _minimumPayment * units;
        require(
            x / units == _minimumPayment,
            "minimumPayment * collateralPerPayment overflows"
        );
    }

  
    /**
     * @dev Prevents overflows
     *
     */
    function multiply(uint256 x, Rational memory r)
        internal
        pure
        returns (uint256)
    {
        return (x * r.numerator) / r.denominator;
    }

    /**
     * @dev Recalculates interest and also conducts check and balances
     *
     */
    function calculateComponents(uint256 amount)
        internal
        view
        returns (uint256 interest, uint256 principal)
    {
        interest = multiply(
            loanBook[msg.sender].remainingBalance,
            loanBook[msg.sender].interestRate
        );
        require(amount >= interest);
        principal = amount - interest;
        return (interest, principal);
    }

    /**
     * @dev he loan is parameterized with collateralPerPayment,
     *which represents the amount of collateral that will be returned
     * or forfeited based on a minimumPayment. If the borrower pays an
     *amount different than the minimum, the amount of collateral returned
     * is adjusted proportionally.
     *
     */
    function calculateCollateral(uint256 payment)
        internal
        view
        returns (uint256 units)
    {
        uint256 product = loanBook[msg.sender].collateralPerPayment * payment;
        require(
            product / loanBook[msg.sender].collateralPerPayment == payment,
            "payment causes overflow"
        );
        units = product / loanBook[msg.sender].minimumPayment;
        return units;
    }

    /**
     * @dev a symmetry between accepting loan payments and handling missed payments.
     * In both cases, there is an adjustment to the remaining principal balance and a
     * corresponding transfer of tokens. The only difference is that the tokens are
     * returned to the borrower after a payment, but they are forfeited to the lender
     * after a missed payment
     *
     *Additional Note: the code above does the token transfer last, which follows the
     * Checks-Effects-Interactions pattern to avoid potential reentrancy vulnerabilities
     */
    function processPeriod(
        uint256 interest,
        uint256 principal,
        address recipient
    ) internal {
        if (recipient == 0x0000000000000000000000000000000000000000) {
            uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += loanBook[msg.sender].paymentPeriod;
        } else {
            uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += loanBook[msg.sender].paymentPeriod;

            require(token.transfer(recipient, units));
        }
    }

    /**
     * @dev Function for the user to make a payment with ETH
     *
     */
    function makePayment() public payable {
        require(block.timestamp <= loanBook[msg.sender].dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(msg.value);

        require(principal <= loanBook[msg.sender].remainingBalance);
        require(
            msg.value >= loanBook[msg.sender].minimumPayment ||
                principal == loanBook[msg.sender].remainingBalance
        );

        processPeriod(interest, principal, msg.sender);
    }

    /**
     * @dev  computes the principal component of the missed payment.
     * This assumes the payment was the minimum amount, which is true
     * for all but, possibly, the last payment. The conditional handles
     * the boundary condition when the principal remaining is less than
     * the principal component of a minimum payment.
     *
     */
    function missedPayment() public {
        require(block.timestamp > loanBook[msg.sender].dueDate);

        uint256 interest;
        uint256 principal;
        (interest, principal) = calculateComponents(
            loanBook[msg.sender].minimumPayment
        );

        if (principal > loanBook[msg.sender].remainingBalance) {
            principal = loanBook[msg.sender].remainingBalance;
        }

        processPeriod(
            interest,
            principal,
            0x0000000000000000000000000000000000000000
        );
    }

    /**
     * @dev  smart contract allows borrowers to pay more than the minimum,
     * which will ultimately lead to less total paid because of avoided interest.
     * If used, this feature will lead to excess collateral owned by the loan contract
     * after it’s been fully paid off. This collateral belongs to the borrower.
     * The simplest way to handle that is to allow excess tokens to be claimed when the remainingBalance is zero:
     *
     */
    function returnCollateral() public {
        require(loanBook[msg.sender].remainingBalance == 0);

        uint256 amount = token.balanceOf(address(this));
        require(token.transfer(msg.sender, amount));
    }

    /**
     * @dev Deletes loan instance once the user has paid his first loan in full
     */
    function cleanSlate() public {
        require(loanBook[msg.sender].remainingBalance == 0);
        delete loanBook[msg.sender];
    }

    // **************************** Staking *******************************

    mapping(address => User) userBook;

    struct User {
        uint256 timeBalanceChanged;
        uint256 stakingBalance;
        uint256 ethBalance;
    }

    function depositEth() public payable {
        require(msg.value >= 1e16, "Error, deposit must be >= 0.01 ETH");

        // Calculate interest based on time passed
        uint256 timeTotal =
            SafeMath.div(
                userBook[msg.sender].timeBalanceChanged,
                block.timestamp
            );
        uint256 staking = SafeMath.div(SafeMath.div(1, 20), timeTotal);
        // Calculate the amount Staked
        uint256 amountStaked =
            SafeMath.mul(userBook[msg.sender].stakingBalance, staking);

        // Save the token interest inside the struct
        userBook[msg.sender].stakingBalance = amountStaked;
        // Reset depositedTime
        userBook[msg.sender].timeBalanceChanged = block.timestamp;
        // Depsit new eth into User's account
        userBook[msg.sender].ethBalance = SafeMath.add(
            userBook[msg.sender].ethBalance,
            msg.value
        );

        emit onReceived(msg.sender, msg.value);
    }

    function withdrawEth(uint256 _amount) public {
        uint256 amount = SafeMath.mul(_amount, 1000000000000000000);
        // Check if amount is within balance bounds
        require(amount <= etherBalance[msg.sender]);
        // Withdraw must be higher than 0.01 ETH
        require(amount >= 1e16, "Error, withdraws must be >= 0.01 ETH");

        uint256 timeTotal =
            SafeMath.div(
                userBook[msg.sender].timeBalanceChanged,
                block.timestamp
            );
        uint256 staking = SafeMath.div(SafeMath.div(1, 20), timeTotal);
        // Calculate the amount Staked
        uint256 amountStaked =
            SafeMath.mul(userBook[msg.sender].stakingBalance, staking);

        // Save the token interest inside the struct
        userBook[msg.sender].stakingBalance = amountStaked;
        // Reset depositedTime
        userBook[msg.sender].timeBalanceChanged = block.timestamp;

        // Substract from the struct
        userBook[msg.sender].ethBalance = SafeMath.sub(
            userBook[msg.sender].ethBalance,
            amount
        );
        // Transfer to user
        msg.sender.transfer(amount);
        emit onTransfer(address(this), msg.sender, amount);
    }

    function viewStaking() public view {
        // Calculate current staking
        uint256 timeTotal =
            SafeMath.div(
                userBook[msg.sender].timeBalanceChanged,
                block.timestamp
            );
        uint256 staking = SafeMath.div(SafeMath.div(1, 20), timeTotal);
        // Calculate the amount Staked
        uint256 amountStaked =
            SafeMath.mul(userBook[msg.sender].stakingBalance, staking);
        // Return previous staking gains plus new staking balance
        SafeMath.add(userBook[msg.sender].stakingBalance, amountStaked);
    }

    function withdrawStaking() public payable {
        uint256 timeTotal =
            SafeMath.div(
                userBook[msg.sender].timeBalanceChanged,
                block.timestamp
            );
        uint256 staking = SafeMath.div(SafeMath.div(1, 20), timeTotal);
        // Calculate the amount Staked
        uint256 amountStaked =
            SafeMath.mul(userBook[msg.sender].stakingBalance, staking);

        //Calculate total
        uint256 total =
            SafeMath.add(userBook[msg.sender].stakingBalance, amountStaked);
        // Reset depositedTime
        userBook[msg.sender].timeBalanceChanged = block.timestamp;
        // Reset staking balace
        userBook[msg.sender].stakingBalance = 0;

        msg.sender.transfer(total);
        onTransfer(address(this), msg.sender, total);
    }

    function verifyLoan() public payable {
        uint256 timePassed =
            SafeMath.sub(block.timestamp, loanBook[msg.sender].timeCreated);

        uint256 yes;
        uint256 no;
        for (uint256 i = 0; i < loanBook[msg.sender].votes.length; i++) {
            if (loanBook[msg.sender].votes[i] == true) {
                yes++;
            } else {
                no++;
            }
        }
        require(timePassed > 604800);
        require(yes > no);

        loanBook[msg.sender].active = true;
        msg.sender.transfer(loanBook[msg.sender].remainingBalance);
    }

    function voteYes(uint256 signature) public {
        loanBook[msg.sender].voters;
    }


}

// ********************************* CHANGES ***************************************

// mapping (uint id => Loan) loanBook;
// signature NFT

// loanBook[id]
// loanBook[id].signature // NFT

// function borrow() {
//     require(loanBook[id].signature == NFT.value)

// }

// ******************************** INCENTIVE SYSTEM *******************************

// tier 1 - Loan  50k - Max voters 100 - 5 per head
//        - msg.sender CBLTs > 300$ worth of ETH
// tier 2 - Loan 100k - Max voters 150 - 7.5 per head
//        - msg.sender CBLTs > 200
// tier 3 - Loan 200k - Max voters 200 - 10 per head
//        - msg.sender CBLTs > 400

// ********************************* TODOS ***********************************

// Starting period, 12-24 months
// Collateral paid on loan application
// Create new function to handle application
// Create a new function to check if loan is ready to loan
// Array of all voters
// Save interest amount on loan to an specific
