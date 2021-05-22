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
    // 0x433C6E3D2def6E1fb414cf9448724EFB0399b698
    IERC20 token;

    /**
     * @dev Creating oracle instance
     */
    ExchangeOracle oracle;

    /**
     * @dev CobaltLend oracle for scoring and CBLT price
     */
    address oracleAddress;

    constructor(address _CBLT, address _oracle) {
        oracle = ExchangeOracle(_oracle);
        token = IERC20(_CBLT);

        // Staking percentages based on deposit time and amount
        stakingRewardRate[1][1].interest = 1;
        stakingRewardRate[1][1].amountStakersLeft = 0;
        stakingRewardRate[1][2].interest = 2;
        stakingRewardRate[1][2].amountStakersLeft = 0;
        stakingRewardRate[1][3].interest = 3;
        stakingRewardRate[1][3].amountStakersLeft = 0;
        stakingRewardRate[1][4].interest = 4;
        stakingRewardRate[1][4].amountStakersLeft = 0;
        stakingRewardRate[1][5].interest = 4;
        stakingRewardRate[1][5].amountStakersLeft = 1000;
        //
        stakingRewardRate[2][1].interest = 1;
        stakingRewardRate[2][1].amountStakersLeft = 0;
        stakingRewardRate[2][2].interest = 2;
        stakingRewardRate[2][2].amountStakersLeft = 0;
        stakingRewardRate[2][3].interest = 3;
        stakingRewardRate[2][3].amountStakersLeft = 0;
        stakingRewardRate[2][4].interest = 4;
        stakingRewardRate[2][4].amountStakersLeft = 0;
        stakingRewardRate[2][5].interest = 4;
        stakingRewardRate[2][5].amountStakersLeft = 0;
        //
        stakingRewardRate[3][1].interest = 1;
        stakingRewardRate[3][1].amountStakersLeft = 0;
        stakingRewardRate[3][2].interest = 2;
        stakingRewardRate[3][2].amountStakersLeft = 0;
        stakingRewardRate[3][3].interest = 3;
        stakingRewardRate[3][3].amountStakersLeft = 0;
        stakingRewardRate[3][4].interest = 4;
        stakingRewardRate[3][4].amountStakersLeft = 0;
        stakingRewardRate[3][5].interest = 4;
        stakingRewardRate[3][5].amountStakersLeft = 0;
        //
        stakingRewardRate[4][1].interest = 3;
        stakingRewardRate[4][1].amountStakersLeft = 500;
        stakingRewardRate[4][2].interest = 5;
        stakingRewardRate[4][2].amountStakersLeft = 500;
        stakingRewardRate[4][3].interest = 5;
        stakingRewardRate[4][3].amountStakersLeft = 500;
        stakingRewardRate[4][4].interest = 5;
        stakingRewardRate[4][4].amountStakersLeft = 1000;
        stakingRewardRate[4][5].interest = 5;
        stakingRewardRate[4][5].amountStakersLeft = 1000;
        //
        stakingRewardRate[5][1].interest = 4;
        stakingRewardRate[5][1].amountStakersLeft = 500;
        stakingRewardRate[5][2].interest = 5;
        stakingRewardRate[5][2].amountStakersLeft = 500;
        stakingRewardRate[5][3].interest = 5;
        stakingRewardRate[5][3].amountStakersLeft = 500;
        stakingRewardRate[5][4].interest = 6;
        stakingRewardRate[5][4].amountStakersLeft = 1000;
        stakingRewardRate[5][5].interest = 7;
        stakingRewardRate[5][5].amountStakersLeft = 1000;
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

<<<<<<< HEAD
    // **************************** Voting *******************************

    mapping(uint256 => mapping(address => bool)) voteBook; // Signature key => mapping( voters => voted)

    mapping(uint256 => address[]) uintArray;
<<<<<<< HEAD
    //
=======

    // mapping(uint => uint) voterCost;

>>>>>>> b374fead5f38a388ced49273b602b3b94035719f
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

=======
>>>>>>> f3fb05f71f97846c82102ff724626038b983b5c6
    // **************************** Staking *******************************

    struct crossTier {
        uint256 interest;
        uint256 amountStakersLeft;
    }

    mapping(uint256 => mapping(uint256 => crossTier)) stakingRewardRate;

    mapping(address => User) public userBook;

    uint256 CBLTReserve = 6000000000000000000000000000;

    uint256 borrowingPool; // 25% use for lending

    struct User {
        uint256 rewardWallet;
        uint256 ethBalance;
        uint256 cbltReserved;
        uint256 depositTime;
        uint256 timeStakedTier;
    }

    function calculateRewardDeposit(
        uint256 _amount,
        uint256 _timeStakedTier,
        uint256 _amountStakedTier,
        uint256 percentBasedAmount
    ) internal returns (uint256) {
        (uint256 CBLTprice, uint256 ETHprice) =
            oracle.priceOfPair(
                address(token),
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
            );

        uint256 userReserved = userBook[msg.sender].cbltReserved;

        // Check if user has CBLT tokens reserved
        if (userReserved > 0) {
            // Calculate the new amount of cblt reserved for user at current market price
            uint256 newReserved =
                SafeMath.div(
                    SafeMath.multiply(
                        SafeMath.multiply(
                            userBook[msg.sender].ethBalance,
                            percentBasedAmount,
                            100
                        ),
                        stakingRewardRate[_timeStakedTier][_amountStakedTier]
                            .interest,
                        100
                    ),
                    CBLTprice
                );

            if (newReserved >= userReserved) {
                // If CBLT price decrease, send all tokens reserved
                userBook[msg.sender].rewardWallet = SafeMath.add(
                    userBook[msg.sender].rewardWallet,
                    userReserved
                );
            } else {
                // If CBLT price increased, calculate the difference between new and old amount final
                uint256 cbltDifference =
                    SafeMath.sub(userReserved, newReserved);

                // Add lefover CBLT tokens back into treasury
                CBLTReserve = SafeMath.add(CBLTReserve, cbltDifference);

                // Save CBLT tokens in contract wallet
                userBook[msg.sender].rewardWallet = SafeMath.add(
                    userBook[msg.sender].rewardWallet,
                    newReserved
                );
            }
        }
        // Calculate and return new CBLT reserved
        return
            SafeMath.div(
                SafeMath.multiply(
                    _amount,
                    stakingRewardRate[_timeStakedTier][_amountStakedTier]
                        .interest,
                    100
                ),
                CBLTprice
            );
    }

    function calculateRewardWithdraw(
        uint256 _amount,
        uint256 _timeStakedTier,
        uint256 _amountStakedTier
    ) internal returns (uint256) {
        uint256 percentBasedAmount = 100;
        uint256 userReserved = userBook[msg.sender].cbltReserved;

        (uint256 CBLTprice, uint256 ETHprice) =
            oracle.priceOfPair(
                address(token),
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
            );

        // Determining if user was sent CBLT tokens on initial staking
        if (
            _timeStakedTier == 4 &&
            (_amountStakedTier == 4 || _amountStakedTier == 5)
        ) {
            percentBasedAmount = 75;
        } else if (
            _timeStakedTier == 5 &&
            (_amountStakedTier == 4 || _amountStakedTier == 5)
        ) {
            percentBasedAmount = 50;
        }

        // If user has CBLT tokens reserved on withdraw, calculate how much is owed to him
        if (userReserved > 0) {
            // Calculate the new amount of cblt reserved for user at current market price
            uint256 newReserved =
                SafeMath.div(
                    SafeMath.multiply(
                        SafeMath.multiply(
                            userBook[msg.sender].ethBalance,
                            percentBasedAmount,
                            100
                        ),
                        stakingRewardRate[_timeStakedTier][_amountStakedTier]
                            .interest,
                        100
                    ),
                    CBLTprice
                );

            if (newReserved >= userReserved) {
                // If CBLT price decrease, send all tokens reserved
                return userReserved;
            } else {
                // If CBLT price increased, calculate the difference between new and old amount final
                uint256 cbltDifference =
                    SafeMath.sub(userReserved, newReserved);

                // Add lefover cblt tokens back into treasury
                CBLTReserve = SafeMath.add(CBLTReserve, cbltDifference);

                // Return new amount of CBLT owed
                return newReserved;
            }
        }
        return 0;
    }

    function depositEth(uint32 _timeStakedTier) public payable {
        uint256 amountStakedTier;
        uint256 paidAdvanced = 0;
        uint256 dueDate;

        // The tier input must be between 1 and 5
        require(
            _timeStakedTier >= 1 && _timeStakedTier <= 5,
            "Tier number must be a number between 1 and 5."
        );

        // Minimum deposit of 0.015 ETH
        require(
            msg.value > 15e16,
            "Error, deposit must be higher than 0.015 ETH"
        );

        // Check the amountStakedTier based on deposit
        if (msg.value <= 4e17) {
            amountStakedTier = 1;
        } else if (msg.value <= 2e18) {
            amountStakedTier = 2;
        } else if (msg.value <= 5e18) {
            amountStakedTier = 3;
        } else if (msg.value <= 25e18) {
            amountStakedTier = 4;
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
            }
        } else {
            amountStakedTier = 5;
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
            }
        }
        // Check if tier has not been depleted
        require(
            stakingRewardRate[_timeStakedTier][amountStakedTier]
                .amountStakersLeft > 0,
            "Tier depleted, come back later"
        );

        // Checking if user is restaking or this is his/her first staking instance
        uint256 stakingPeriod = userBook[msg.sender].timeStakedTier;

        if (stakingPeriod > 0) {
            // Create due date based on deposite time and time Tier
            if (stakingPeriod == 1) {
                dueDate = SafeMath.add(
                    userBook[msg.sender].depositTime,
                    2629743
                );
            } else if (stakingPeriod == 2) {
                dueDate = SafeMath.add(
                    userBook[msg.sender].depositTime,
                    5259486
                );
            } else if (stakingPeriod == 3) {
                dueDate = SafeMath.add(
                    userBook[msg.sender].depositTime,
                    7889229
                );
            } else if (stakingPeriod == 4) {
                dueDate = SafeMath.add(
                    userBook[msg.sender].depositTime,
                    15778458
                );
            } else {
                dueDate = SafeMath.add(
                    userBook[msg.sender].depositTime,
                    31556916
                );
            }
            // Revert if staking period is not over
            require(
                block.timestamp > dueDate,
                "Current staking period is not over yet"
            );
        }

        // Checks the amount of CBLT tokens that need to be reserved
        uint256 cbltReserved =
            calculateRewardDeposit(
                msg.value,
                _timeStakedTier,
                amountStakedTier,
                SafeMath.sub(100, paidAdvanced)
            );

        // Treasury must have that amount open
        require(cbltReserved <= CBLTReserve, "Treasury is currently depleted");

        // Check if we are sending CBLT based on time staked
        if (paidAdvanced > 0) {
            uint256 cbltSent =
                SafeMath.multiply(cbltReserved, paidAdvanced, 100);
            // require( token.transfer(msg.sender, cbltSent), "Transaction was not successful" );

            // Saves the amount of CBLT tokens reserved minus the amount sent in advanced
            userBook[msg.sender].cbltReserved = SafeMath.add(
                userBook[msg.sender].cbltReserved,
                SafeMath.multiply(
                    cbltReserved,
                    SafeMath.sub(100, paidAdvanced),
                    100
                )
            );
        } else {
            // Saves the amount of CBLT tokens reserved in user struct
            userBook[msg.sender].cbltReserved = SafeMath.add(
                userBook[msg.sender].cbltReserved,
                cbltReserved
            );
        }

        // Save amount of time staked
        userBook[msg.sender].timeStakedTier = _timeStakedTier;

        // Substract CBLT tokens reserved for user from treasury
        CBLTReserve = SafeMath.sub(CBLTReserve, cbltReserved);

        // Oracle call for current ETH price in USD
        uint256 ETHprice = oracle.priceOfETH();

        // Dollar fee based
        uint256 ETHinUSD = SafeMath.div(100000000000000000000, ETHprice);

        // Save new eth deposit in user account
        userBook[msg.sender].ethBalance = SafeMath.add(
            userBook[msg.sender].ethBalance,
            SafeMath.sub(msg.value, ETHinUSD)
        );

        // Decrease number of stakers avaliable for current tier based on time and amount
        stakingRewardRate[_timeStakedTier][amountStakedTier]
            .amountStakersLeft = SafeMath.sub(
            stakingRewardRate[_timeStakedTier][amountStakedTier]
                .amountStakersLeft,
            1
        );

        // Change the time of deposit
        userBook[msg.sender].depositTime = block.timestamp;
    }

    function withdrawEth(uint256 _amount) public {
        uint256 dueDate;
        uint256 stakingPeriod = userBook[msg.sender].timeStakedTier;
        uint256 _amountStakedTier;
        uint256 userBalance = userBook[msg.sender].ethBalance;

        // Calulate due date based on time staked tier and deposit time
        if (stakingPeriod == 1) {
            dueDate = SafeMath.add(userBook[msg.sender].depositTime, 2629743);
        } else if (stakingPeriod == 2) {
            dueDate = SafeMath.add(userBook[msg.sender].depositTime, 5259486);
        } else if (stakingPeriod == 3) {
            dueDate = SafeMath.add(userBook[msg.sender].depositTime, 7889229);
        } else if (stakingPeriod == 4) {
            dueDate = SafeMath.add(userBook[msg.sender].depositTime, 15778458);
        } else {
            dueDate = SafeMath.add(userBook[msg.sender].depositTime, 31556916);
        }
        // Staking period must be over before he withdraws ETH balance
        require(block.timestamp >= dueDate, "Staking period is not over.");

        // Determine the amount staked tier based on ETH balance
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
        // Recalculate total CBLT tokens based on current token value
        uint256 stakingReward =
            calculateRewardWithdraw(
                userBook[msg.sender].ethBalance,
                stakingPeriod,
                _amountStakedTier
            );
        // Save reward in wallet
        userBook[msg.sender].rewardWallet = SafeMath.add(
            userBook[msg.sender].rewardWallet,
            stakingReward
        );
        // Reset amount of CBLT reserved
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

        // token.transfer(address(this), msg.sender, _amount);
    }

    function changeInterest(
        uint256 _timeStakedTier,
        uint256 _amountStakedTier,
        uint256 _newInterest
    ) public {
        // Only devs
        stakingRewardRate[_timeStakedTier][_amountStakedTier]
            .interest = _newInterest;
    }
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
