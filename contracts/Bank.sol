pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./ExchangeOracle.sol";

contract Bank is Ownable {
    using UniversalERC20 for IERC20;

    /**
     * @dev storing CBLT token in ERC20 type
     */
    IERC20 token;

    /**
     * @dev CobaltLend oracle for scoring and CBLT price
     */
    address oracleAddress;

    constructor(
        address[] memory addresses,
        address _CBLT,
        address _oracle
    ) {
        for (uint256 i = 0; i < addresses.length; i++) {
            tokensAllowed[addresses[i]] = true;
        }
        oracleAddress = _oracle;
        token = IERC20(_CBLT);
        // Staking percentages based on deposit time and amount
        stakingRewardRate[1][1] = 5;
        stakingRewardRate[1][2] = 6;
        stakingRewardRate[1][3] = 7;
        stakingRewardRate[1][4] = 8;
        stakingRewardRate[1][5] = 9;
        //
        stakingRewardRate[2][1] = 6;
        stakingRewardRate[2][2] = 7;
        stakingRewardRate[2][3] = 8;
        stakingRewardRate[2][4] = 9;
        stakingRewardRate[2][5] = 10;
        //
        stakingRewardRate[3][1] = 7;
        stakingRewardRate[3][2] = 8;
        stakingRewardRate[3][3] = 9;
        stakingRewardRate[3][4] = 10;
        stakingRewardRate[3][5] = 14;
        //
        stakingRewardRate[4][1] = 9;
        stakingRewardRate[4][2] = 11;
        stakingRewardRate[4][3] = 13;
        stakingRewardRate[4][4] = 15;
        stakingRewardRate[4][5] = 17;
        //
        stakingRewardRate[5][1] = 10;
        stakingRewardRate[5][2] = 13;
        stakingRewardRate[5][3] = 16;
        stakingRewardRate[5][4] = 19;
        stakingRewardRate[5][5] = 20;
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

        token = IERC20(address(_tokenAddress));

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

        payable(msg.sender).transfer(_amount);

        emit onTransfer(msg.sender, address(0), _amount);
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
     * @dev allows for chromium contract to see which tokens
     * are allowed to be deposited into treasury
     */
    function isTokenAllowed(address _token) public view returns (bool) {
        return tokensAllowed[_token];
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
        etherBalance[address(this)] = SafeMath.add(
            etherBalance[address(this)],
            msg.value
        );
        emit onReceived(msg.sender, msg.value);
    }

    // ****************************** Lending **********************************

    /**
     * @dev mapping used to store all loan information with the key of borrower address
     *  and value of Loan struct with all loan information
     */
    mapping(address => Loan) loanBook;

    /**
     * @dev mapping used to record information on loan tiers i.e. maximum period, votes
     */
    mapping(uint256 => Tier) tierBook;

    /**
     * @dev mapping used to record information on loan tiers i.e. maximum period, votes
     */
    struct Tier {
        uint128 voterLimit;
        uint128 maximumPeriodPayment;
    }

    /**
     * @dev Struct to store loan information
     */
    struct Loan {
        address borrower; // Address of wallet
        uint256 remainingBalance; // Remaining balance
        uint256 minimumPayment; // MinimumPayment // Can be calculated off total amount
        bool active; // Is the current loan active (Voted yes)
        bool initialized; // Does the borrower have a current loan application
        uint64 dueDate; // Time of contract ending
        uint64 timeCreated; // Time of loan application also epoch in days
        uint64 totalVote; // Total amount determined by tier
        uint64 yes; // Amount of votes for yes
    }

    /**
     * @dev Recalculates interest and also conducts check and balances
     */

    function newLoan(uint256 _paymentPeriod, uint256 principal) public payable {
        // require(_paymentPeriod <= )

        uint256 riskScore = 20; // NFT ENTRY!!!!!!
        uint256 riskFactor = 15; // NFT ENTRY!!!!
        uint256 numerator = 2; // NFT ENTRY!!!!

        // Pulling prices from Oracle
        (bool result, bytes memory data) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "getValue(address)",
                    0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e
                )
            );

        // Check if oracle is functional
        require(result == true, "Oracle is down");

        uint256 tokenPrice = abi.decode(data, (uint256));

        // Calculate collateral in CBLT based on principal, riskScore and riskFactor
        uint256 collateralInCBLT =
            SafeMath.div(
                SafeMath.multiply(
                    SafeMath.mul(riskScore, riskFactor),
                    principal,
                    1000
                ),
                tokenPrice
            );

        // Payment in
        uint256 paymentPeriodInMonths = SafeMath.div(_paymentPeriod, 2629743);

        uint256 collateralPerPayment =
            SafeMath.div(collateralInCBLT, paymentPeriodInMonths);

        require(loanBook[msg.sender].initialized == false);

        require(
            token.transferFrom(msg.sender, address(this), collateralInCBLT) ==
                true,
            "Payment was not approved."
        );

        // loanBook[msg.sender] = Loan(
        //     msg.sender,
        //     (block.timestamp + _paymentPeriod),
        //     // Rational(numerator, denominator),
        //     _paymentPeriod,
        //     principal,
        //     // _minimumPayment, // Needs to be calculated!!!!!!
        //     collateralPerPayment,
        //     false,
        //     true,
        //     block.timestamp,
        //     0,
        //     0,
        //     0,
        //     0
        // );

        uint256 timeCreated; // Time of loan application
        uint256 yes; // Amount of votes for yes
        uint256 no; // Amount of votes for no
        uint256 totalVote; // Total amount determined by tier
        uint256 tier; // Tier based on amount intended to be borrowed

        // uint256 x = _minimumPayment * units; // NEEDS TO BE WORKED AT NIGTHT!!!!!!!!
        // require(
        //     x / units == _minimumPayment,
        //     "minimumPayment * collateralPerPayment overflows"
        // );
    }

    /**
    function tallyVotes() public {}

    /**
     * @dev Prevents overflows
     *
     */
    // function multiplyDecimal(uint256 x, Rational memory r)
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     return (x * r.numerator) / r.denominator;
    // }

    /**
     * @dev Recalculates interest and also conducts check and balances
     *
     */
    function calculateComponents(uint256 amount)
        internal
        view
        returns (uint256 interest, uint256 principal)
    {
        // interest = multiply(
        //     loanBook[msg.sender].remainingBalance,
        //     loanBook[msg.sender].interestRate
        // );
        require(amount >= interest);
        principal = amount - interest;
        return (interest, principal);
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
            // uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += 30; // days
        } else {
            // uint256 units = calculateCollateral(interest + principal);

            loanBook[msg.sender].remainingBalance -= principal;

            loanBook[msg.sender].dueDate += 30; // days
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

    // **************************** Voting *******************************

    mapping(uint256 => mapping(address => bool)) voteBook; // Signature key => mapping( voters => voted)

    mapping(uint256 => address[]) uintArray;

    // mapping(uint => uint) voterCost;

    // User tries to vote
    // Contract checks if they have sufficient funds in CBLT tokens - Tiers
    // Function checks if 7 days have passsed since loan first went into voting
    // Function checks if loan array has a length <= tier max
    // Voter casts votes
    // Vote gets added to counter to yes or no in loan
    // msg.sender is added to uintArray - Access with the unique signature for each loan
    // Validate loan checking if enough votes have been casted. 21% of the votes
    // Check if majority of the votes say yes or no
    // Change loan status depending on how voting went
    // Give second wind to the loan depending on if its the first time
    // Reset voting but keep voters inside
    // Update 1 ---
    // -------- Add an address array to keep track of the users we owe interest to
    // -------- No second-wind option for loans (being discussed)
    // -------- Payout for voters occurs at the end but payment of interest is prioritized

    enum State {Created, Voting, Ended}
    State public state;

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    /**
     * @dev creating function the right to vote
     * if a person holds a certain amount of CBLT
     * they can for tier 1
     *
     */
    function rightToVoteTiers(address loanSignature) internal view {
        uint256 balanceInCBLT =
            SafeMath.add(
                token.balanceOf(msg.sender),
                userBook[msg.sender].rewardWallet
            );

        // PULL FROM ORACLE // ORACLE ENTRY!!!!!
        uint256 USDtoCBLT =
            SafeMath.div(
                1000000000000000000,
                SafeMath.mul(2000000000000, 2843)
            );
    }

    /**
     * @dev starts the voting process
     *
     */
    function startVote() internal inState(State.Created) {
        state = State.Voting;
    }

    /**
     * @dev DOES the vote takes in the voter choice
     *
     */

    function doVote(uint256 _signature, bool _vote)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        // bool found = false;
        // require(
        //     voteBook[_signature][msg.sender] == false,
        //     "You have already voted."
        // );
        // voteBook[_signature][msg.sender] = true;
        // if (_vote == true) {
        //     loanBook[msg.sender].yes++;
        // } else {
        //     loanBook[msg.sender].no++;
        // }
        // loanBook[msg.sender].totalVote++;
        // return true;
    }

    /**
     * @dev Ends the voting
     *
     */

    function endVote() internal inState(State.Voting) {
        // the  1619656173 represents 7 days in epoch and must be less then 7 days
        uint256 weekOfEpoch = 1619656173;

        // in which it requires at least 50% of the voters to past
        // will not use multiple ifs for tiers to save on gas
        if (loanBook[msg.sender].timeCreated <= weekOfEpoch) {
            require(
                SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 100) >= 50
            );
            require(
                SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 200) >= 50
            );
            require(
                SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 400) >= 50
            );
            require(
                SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 800) >= 50
            );
            require(
                SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 1600) >=
                    50
            );

            state = State.Ended;
        } else {
            state = State.Ended;
        }
    }

    //How to give voters another chance if the someone did not vote needs to be added
    // in

    // if voting is past 7 days then loan ends. Must take 21 votes

    // **************************** Staking *******************************

    // Pools

    mapping(uint256 => mapping(uint256 => uint256)) stakingRewardRate;

    mapping(address => User) public userBook;

    uint256 CBLTReserve = 100000000000000000000000000000000000;

    struct User {
        uint256 depositTime;
        uint256 rewardWallet;
        uint256 ethBalance;
        uint256 cbltReserved;
        uint256 timeStakedTier;
        uint256 ethStaked;
    }

    function calculateReward(
        uint256 _amount,
        uint256 _timeStakedTier,
        uint256 _amountStakedTier
    ) internal returns (uint256) {
        // uint256 tokenPrice = 2000000000000;
        // Pull token price from oracle
        (bool result, bytes memory data) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "getValue(address)",
                    0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e
                )
            );
        require(result == true, "Oracle is down");

        // Decode bytes data
        uint256 tokenPrice = abi.decode(data, (uint256));

        if (userBook[msg.sender].cbltReserved > 0) {
            // Calculate the new amount of cblt reserved for user at current market price
            uint256 newReserved =
                SafeMath.div(
                    SafeMath.multiply(
                        _amount,
                        stakingRewardRate[_timeStakedTier][_amountStakedTier],
                        100
                    ),
                    tokenPrice
                );
            // Calculate the difference between new and old amount
            uint256 cbltDifference =
                SafeMath.sub(userBook[msg.sender].cbltReserved, newReserved);

            if (cbltDifference == 0) {
                return userBook[msg.sender].cbltReserved;
            } else {
                // Add lefover cblt tokens back into treasury
                CBLTReserve = SafeMath.add(CBLTReserve, cbltDifference);
                // Return the new staking reward
                return newReserved;
            }
        } else {
            return
                SafeMath.div(
                    SafeMath.multiply(
                        _amount,
                        stakingRewardRate[_timeStakedTier][_amountStakedTier],
                        100
                    ),
                    tokenPrice
                );
        }
    }

    function depositEth(uint256 _timeStakedTier) public payable {
        require(
            _timeStakedTier > 0 && _timeStakedTier < 6,
            "Tier number must be a number between 1 and 5."
        );

        // Check the amountStakedTier based on deposit
        uint256 _amountStakedTier;

        if (msg.value <= 4e17) {
            _amountStakedTier = 1;
        } else if (msg.value <= 2e18) {
            _amountStakedTier = 2;
        } else if (msg.value <= 5e18) {
            _amountStakedTier = 3;
        } else if (msg.value <= 25e18) {
            _amountStakedTier = 4;
        } else {
            _amountStakedTier = 5;
        }

        userBook[msg.sender].ethStaked = _amountStakedTier; // TESTING GET RID OFF!!!!!!!!

        // Minimum deposit of 0.015 ETH
        require(msg.value >= 15e16, "Error, deposit must be >= 0.015 ETH");

        // Checks the amount of CBLT tokens that need to be reserved
        uint256 cbltReserved =
            calculateReward(msg.value, _timeStakedTier, _amountStakedTier);

        // Treasury must have that amount open
        require(cbltReserved <= CBLTReserve, "Treasury is currently depleted");

        // Substract CBLT tokens reserved for stake from treasury
        CBLTReserve = SafeMath.sub(CBLTReserve, cbltReserved);

        // Saves the amount of CBLT tokens reserved in user struct
        userBook[msg.sender].cbltReserved = SafeMath.add(
            userBook[msg.sender].cbltReserved,
            cbltReserved
        );

        // Save information on the time tier
        userBook[msg.sender].timeStakedTier = _timeStakedTier;

        // Save new eth deposit in user account
        userBook[msg.sender].ethBalance = SafeMath.add(
            userBook[msg.sender].ethBalance,
            msg.value
        );

        // Change the time of deposit
        userBook[msg.sender].depositTime = block.timestamp;

        emit onReceived(msg.sender, msg.value);
    }

    function withdrawEth(uint256 _amount) public {
        // Calulate how many months since first staked

        uint256 monthsAfterDeposit =
            SafeMath.div(
                SafeMath.sub(block.timestamp, userBook[msg.sender].depositTime),
                2629743
            );

        // Make sure user staked for at least 1 month
        require(monthsAfterDeposit >= 1, "Wait 30 days to withdraw");

        uint256 _amountStakedTier;

        uint256 userBalance = userBook[msg.sender].ethBalance;

        if (userBalance <= 4e17) {
            _amountStakedTier = 5;
        } else if (userBalance <= 2e18) {
            _amountStakedTier = 4;
        } else if (userBalance <= 5e18) {
            _amountStakedTier = 3;
        } else if (userBalance <= 25e18) {
            _amountStakedTier = 2;
        } else {
            _amountStakedTier = 1;
        }

        uint256 stakedPeriodMonths;

        if (userBook[msg.sender].timeStakedTier == 1) {
            stakedPeriodMonths = 1;
        } else if (userBook[msg.sender].timeStakedTier == 2) {
            stakedPeriodMonths = 2;
        } else if (userBook[msg.sender].timeStakedTier == 3) {
            stakedPeriodMonths = 3;
        } else if (userBook[msg.sender].timeStakedTier == 4) {
            stakedPeriodMonths = 6;
        } else {
            stakedPeriodMonths = 12;
        }

        // Recalculate total CBLT tokens based on current token value
        uint256 stakingReward =
            calculateReward(
                userBook[msg.sender].ethBalance,
                userBook[msg.sender].timeStakedTier,
                _amountStakedTier
            );
        // Calculate staking reward based on months staked
        uint256 monthBasedReward =
            SafeMath.multiply(
                stakingReward,
                monthsAfterDeposit,
                stakedPeriodMonths
            );

        // Save reward in wallet
        userBook[msg.sender].rewardWallet = SafeMath.add(
            userBook[msg.sender].rewardWallet,
            stakingReward
        );

        userBook[msg.sender].cbltReserved = 0;

        // Substract eth from user account
        userBook[msg.sender].ethBalance = SafeMath.sub(
            userBook[msg.sender].ethBalance,
            _amount
        );
        // Change the latest time of deposit
        userBook[msg.sender].depositTime = block.timestamp;

        payable(msg.sender).transfer(_amount);
    }

    function testUserData()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            userBook[msg.sender].ethBalance,
            userBook[msg.sender].depositTime,
            userBook[msg.sender].cbltReserved,
            userBook[msg.sender].timeStakedTier,
            userBook[msg.sender].ethStaked
        );
    }

    function withdrawStaking(uint256 _amount) public payable {
        // Pull token price from oracle
        (bool call1, bytes memory tokenPriceEncoded) =
            oracleAddress.call(
                abi.encodeWithSignature(
                    "getValue(address)",
                    0x29a99c126596c0Dc96b02A88a9EAab44EcCf511e
                )
            );
        require(call1 == true, "Oracle is down.");

        // Pull ETH price in USD
        (bool call2, bytes memory ethPriceUSD) =
            oracleAddress.call(abi.encodeWithSignature("getETHinUSD()"));

        require(call2 == true, "Oracle is down.");

        // Decode bytes data
        uint256 tokenPrice = abi.decode(tokenPriceEncoded, (uint256));
        uint256 ETHinUSD = abi.decode(ethPriceUSD, (uint256));

        uint256 USDtoCBLT =
            SafeMath.div(
                100000000000000000000,
                SafeMath.mul(tokenPrice, ETHinUSD) // A and B coming from oracle
            );

        require(
            userBook[msg.sender].rewardWallet >= SafeMath.mul(USDtoCBLT, 50),
            "Reward wallet does not have 50$"
        );

        userBook[msg.sender].rewardWallet = 0;

        token.universalTransferFrom(address(this), msg.sender, _amount);
    }
    // Voting
    // Lending
    // Cobalt tokens saved on amount staked
    // Wallet only updated when user deposits or withdraws
    // Fixed period loans
    // Functions check the current balance the treasury has avaliable to stake
    // Tier system in place
    // Function to recalculate amount of cblt tokens reserved based on amount staked
    // 30 60 90 180 365
}

// 7 days
// 3 missed payments back to back
// 4 missed payment overall
// 6 years 100k ++++
// 2 years 100k ----

// ************************************* CHANGES ************************************

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

// ************************************** TODOS ************************************

// Starting period, 12-24 months
// Collateral paid on loan application
// Create new function to handle application
// Create a new function to check if loan is ready to loan
// Array of all voters
// Save interest amount on loan to an specific

// Calling oracle from ABI

// (bool result, bytes memory data) =
//             oracleAddress.call(
//                 abi.encodeWithSignature(
//                     "priceOfPair(address,address)",
//                     _sellToken,
//                     _buyToken
//                 )
//             );
//         // Decode bytes data
//         (uint256 sellTokenValue, uint256 buyTokenValue) =
//             abi.decode(data, (uint256, uint256));

// Amount of CBLT present in wallet per tier

// Tier 1 - 500  to  5k   USD
// Tier 2 - 5k   to  20k  USD
// Tier 3 - 20k  to  50k  USD
// Tier 4 - 50k  to  100k USD
// Tier 5 - 100k to  250k USD
// Tier 6 - +250k         USD

// Amount of votes allowed per tier

// Tier 1 - 20
// Tier 2 - 40
// Tier 3 - 60-80
// Tier 4 ''  '' '' Needs work

// Information made public from the borrower
// Name, eth account, email

// Maximum period to pay loan per Tier
// Tier 1 - 10k  to 25k  - 12 months
// Tier 2 - 25k  to 50k  - 24 months
// Tier 3 - 50k  to 100k - 36 months
// Tier 4 - 100k to 250k - 48 months
// Tier 5 - 250k to 1m   - 60 months
// Tier 6 - 1m   to 5m   - 60 months
// Tier 7 - 5m and above - 60 months

// New contract logic needed to be added
// Lending 50%
// Long term stakers - 12
// long term pool
// staking - indebt

// Points of entry, restricting value
// Validate

// 25% - 6
// 50% - 12

// FUNCTION TO VALIDATE LENDING

// function validate(address[] memory _votersAddress, bool _voteFinal, uint _loanSignature ) public { // only devs
//     // Oracle inject
//     // loanbook[_loanSignature].tierUSD;

//     uint256 USDtoCBLT =
//         SafeMath.div(
//             1000000000000000000,
//             SafeMath.mul(2000000000000, 2843)
//         );

//     for(uint i = 0; i < _votersAddress.length;i++) { // 8 // 100
//          _votersAddress[i];
//          // uint tierVoters = loanbook[_loanSignature].maxVoters;
//          // Two things
//          // token.balanceOf(_votersAddress[i]);
//     }
//     // loanbook[_loanSignature].status;
// }
