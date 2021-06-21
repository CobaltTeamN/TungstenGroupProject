// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./ExchangeOracle.sol";

// 0x433C6E3D2def6E1fb414cf9448724EFB0399b698

contract Bank is Ownable {
    using UniversalERC20 for IERC20;

    // ********************************** CONTRACT CONTROL *********************************
    /**
     * @dev storing CBLT token in ERC20 type
     */
    IERC20 token;

    /**
     * @dev Creating oracle instance
     */
    ExchangeOracle oracle;

    /**
     * @dev CobaltLend oracle for scoring and CBLT price
     */
    address oracleAddress;

    /**
     * @dev Bool switch turns support for other tokens as reward outside of CBLT.
     */
    bool multipleTokenSupport;

    /**
     * @dev Variable to turn staking off and on.
     */
    bool public stakingStatus;

    /**
     * @dev Bool switch for all staking instance terminations
     */
    bool public terminateStaking;

    /**
     * @dev Mapping with key value address (token address) leads the current reserves avaliable for tokens
     * being currently offered to stake on.
     */
    mapping(address => uint256) public tokenReserve;

    /**
     * @dev Checks if all current staking instances are to be terminated
     */
    modifier stakingTermination(bool _functionSpecific) {
        if (_functionSpecific) {
            require(terminateStaking == true, "Staking is currently disabled.");
        } else {
            require(
                terminateStaking == false,
                "Staking is currently functioning as expected"
            );
        }
        _;
    }

    /**
     * @dev Getter function to pull info on support for other tokens.
     */
    function getTokenSupport() public view returns (bool) {
        return multipleTokenSupport;
    }

    /**
     * @dev Getter function to pull information for avaliable token amount in reserves
     * @param _tokenAddress token address of queried token
     */
    function getTokenReserve(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return tokenReserve[_tokenAddress];
    }

    /**
     * @dev Getter function to pull staking status on and off.
     */
    function getStakingStatus() public view returns (bool) {
        return stakingStatus;
    }

    /**
     * @dev Function terminates all staking instances and allows early balance withdrewal
     * @param _bool true terminates all contract instances and allows users to withdraw
     * @notice This action can only be perform under dev vote.
     */
    function setStakingTermination(bool _bool) public {
        terminateStaking = _bool;
    }

    /**
     * @dev Setter function to turn support for other tokens.
     * @notice This action can only be perform under dev vote.
     * @param _bool true turns on other token support for staking reward, false off
     */
    function setTokenSupport(bool _bool) public {
        multipleTokenSupport = _bool;
    }

    /**
     * @dev Setter function to turn staking status on and off.
     * @notice This action can only be perform under dev vote.
     * @param _bool value true - on, false - off.
     */
    function setStakingStatus(bool _bool) public {
        stakingStatus = _bool;
    }

    /**
     * @dev Function handles token deposit for treasury to track
     */
    function tokenReserveDeposit(uint256 _amount, address _tokenAddress)
        public
        payable
    {
        IERC20(_tokenAddress).universalTransferFromSenderToThis(_amount);
        tokenReserve[_tokenAddress] = SafeMath.add(
            tokenReserve[_tokenAddress],
            _amount
        );
    }

    constructor(address _CBLT, address _oracle) {
        oracle = ExchangeOracle(_oracle);
        token = IERC20(_CBLT);

        // loanTiers[5].maxVoters = 100;
        // loanTiers[5].maximumPaymentPeriod = 60;
        // loanTiers[5].principalLimit = 500000;

        tokenReserve[
            0x433C6E3D2def6E1fb414cf9448724EFB0399b698
        ] = 6000000000000000000000000000;
        tokenReserve[
            0xc778417E063141139Fce010982780140Aa0cD5Ab
        ] = 6000000000000000000000000000;

        tierMax = 5;
        multipleTokenSupport = false;
        stakingStatus = true;
        flatFee = 3;
        percentFee = 3;
        terminateStaking = false;
        feeThreshold = 5e18;

        // Staking percentages based on deposit time and amount
        stakingRewardRate[1][1].interest = 1;
        stakingRewardRate[1][1].amountStakersLeft = 0;
        stakingRewardRate[1][1].tierDuration = 1800;
        stakingRewardRate[1][2].interest = 2;
        stakingRewardRate[1][2].amountStakersLeft = 0;
        stakingRewardRate[1][2].tierDuration = 1800;
        stakingRewardRate[1][3].interest = 3;
        stakingRewardRate[1][3].amountStakersLeft = 0;
        stakingRewardRate[1][3].tierDuration = 1800;
        stakingRewardRate[1][4].interest = 4;
        stakingRewardRate[1][4].amountStakersLeft = 0;
        stakingRewardRate[1][4].tierDuration = 1800;
        stakingRewardRate[1][5].interest = 4;
        stakingRewardRate[1][5].amountStakersLeft = 0;
        stakingRewardRate[1][5].tierDuration = 1800;
        //
        stakingRewardRate[2][1].interest = 1;
        stakingRewardRate[2][1].amountStakersLeft = 0;
        stakingRewardRate[2][1].tierDuration = 3600;
        stakingRewardRate[2][2].interest = 2;
        stakingRewardRate[2][2].amountStakersLeft = 0;
        stakingRewardRate[2][2].tierDuration = 3600;
        stakingRewardRate[2][3].interest = 3;
        stakingRewardRate[2][3].amountStakersLeft = 0;
        stakingRewardRate[2][3].tierDuration = 3600;
        stakingRewardRate[2][4].interest = 4;
        stakingRewardRate[2][4].amountStakersLeft = 0;
        stakingRewardRate[2][4].tierDuration = 3600;
        stakingRewardRate[2][5].interest = 4;
        stakingRewardRate[2][5].amountStakersLeft = 0;
        stakingRewardRate[2][5].tierDuration = 3600;
        //
        stakingRewardRate[3][1].interest = 1;
        stakingRewardRate[3][1].amountStakersLeft = 0;
        stakingRewardRate[3][1].tierDuration = 5400;
        stakingRewardRate[3][2].interest = 2;
        stakingRewardRate[3][2].amountStakersLeft = 0;
        stakingRewardRate[3][2].tierDuration = 5400;
        stakingRewardRate[3][3].interest = 3;
        stakingRewardRate[3][3].amountStakersLeft = 0;
        stakingRewardRate[3][3].tierDuration = 5400;
        stakingRewardRate[3][4].interest = 4;
        stakingRewardRate[3][4].amountStakersLeft = 0;
        stakingRewardRate[3][4].tierDuration = 5400;
        stakingRewardRate[3][5].interest = 4;
        stakingRewardRate[3][5].amountStakersLeft = 0;
        stakingRewardRate[3][5].tierDuration = 5400;
        //
        stakingRewardRate[4][1].interest = 2;
        stakingRewardRate[4][1].amountStakersLeft = 500;
        stakingRewardRate[4][1].tierDuration = 10800;
        stakingRewardRate[4][2].interest = 3;
        stakingRewardRate[4][2].amountStakersLeft = 500;
        stakingRewardRate[4][2].tierDuration = 10800;
        stakingRewardRate[4][3].interest = 4;
        stakingRewardRate[4][3].amountStakersLeft = 500;
        stakingRewardRate[4][3].tierDuration = 10800;
        stakingRewardRate[4][4].interest = 5;
        stakingRewardRate[4][4].amountStakersLeft = 1000;
        stakingRewardRate[4][4].tierDuration = 10800;
        stakingRewardRate[4][5].interest = 6;
        stakingRewardRate[4][5].amountStakersLeft = 1000;
        stakingRewardRate[4][5].tierDuration = 10800;
        //
        stakingRewardRate[5][1].interest = 3;
        stakingRewardRate[5][1].amountStakersLeft = 500;
        stakingRewardRate[5][1].tierDuration = 21360;
        stakingRewardRate[5][2].interest = 4;
        stakingRewardRate[5][2].amountStakersLeft = 500;
        stakingRewardRate[5][2].tierDuration = 21360;
        stakingRewardRate[5][3].interest = 5;
        stakingRewardRate[5][3].amountStakersLeft = 500;
        stakingRewardRate[5][3].tierDuration = 21360;
        stakingRewardRate[5][4].interest = 6;
        stakingRewardRate[5][4].amountStakersLeft = 1000;
        stakingRewardRate[5][4].tierDuration = 21360;
        stakingRewardRate[5][5].interest = 7;
        stakingRewardRate[5][5].amountStakersLeft = 1000;
        stakingRewardRate[5][5].tierDuration = 21360;
    }

    /**
     * @dev
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // ******************************** Fee mechanism ***********************************

    /**
     * @dev
     */
    uint256 public feeThreshold;

    /**
     * @dev Variable for staking flat fee.
     */
    uint256 public flatFee;

    /**
     * @dev Variable for staking flat fee.
     */
    uint256 public percentFee;

    /**
     * @dev
     */
    address WithdrawContract;

    /**
     * @dev Saving running fee total
     */
    uint256 public totalFeeBalance;

    modifier onlyTreasury {
        require(
            msg.sender == WithdrawContract,
            "This address can't withdraw funds from treasury"
        );
        _;
    }

    /**
     * @dev
     */
    function setContract(address _treasuryAddress) public {
        WithdrawContract = _treasuryAddress;
    }

    /**
     * @dev
     */
    function getTotalBalance() public view returns (uint256) {
        return totalFeeBalance;
    }

    /**
     * @dev transfers funds to an approved contract
     */
    function withdrawFees(uint256 _amount) public payable onlyTreasury {
        require(
            _amount <= totalFeeBalance,
            "Treasury doesn't have sufficient funds."
        );
        totalFeeBalance = SafeMath.sub(totalFeeBalance, _amount);
        payable(msg.sender).transfer(_amount);
    }

    /**
     * @dev Setter for staking flat fee.
     * @param _newFee new uint fee value.
     * @notice This action can only be perform under dev vote.
     */
    function newFlatFee(uint256 _newFee) public {
        flatFee = _newFee;
    }

    function newPercentFee(uint256 _newFee) public {
        percentFee = _newFee;
    }

    // **************************************** DEV VOTE ************************************************

    event Received(address, uint256);

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

    mapping(address => bool) devBook;
    address[] devArray;
    address addressProposed;
    string proposedChange;
    uint256 intProposed;
    uint256 _amountTier;
    uint256 _timeTier;
    uint256 _interest;
    uint256 _amountStakersLeft;
    uint256 _tierDuration;
    bool boolProposed;

    modifier clearedAction(
        uint256 percentage,
        string memory _currentChange,
        string memory _proposedChange
    ) {
        uint256 votes;
        uint256 totalVotes = devArray.length;

        for (uint256 i = 0; i < devArray.length; i++) {
            if (devBook[devArray[i]] == true) {
                votes++;
            }
        }

        require(SafeMath.multiply(votes, totalVotes, 100) >= percentage);
        require(bytes(_proposedChange).length == bytes(_currentChange).length);

        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]] = false;
        }
        _;
    }

    function proposeNumberChange(uint256 _num) public {
        for (uint256 i = 0; i < devArray.length; i++) {
            devBook[devArray[i]] = false;
        }
        intProposed = _num;
        proposedChange = "number";
    }

    function proposeTierChange(
        uint256 _amountTier,
        uint256 _timeTier,
        uint256 _interest,
        uint256 _amountStakersLeft,
        uint256 _tierDuration
    ) public {}

    // need modifier for public functions
    // function proposeBoolChange(bool _bool) public {}
    // proposeAddressChange(address _address)  proposedChange = "string"
    // addDevTeam
    // deleteDevTeam

    // function changeInterest()
    //     public
    //     clearedAction(75, "number", proposedChange)
    // {
    //     uint256 interest = intProposed;
    // }

    // ************************************ Lottery ***************************************
    /**
     * @dev Address of lottery contract in charge of executing LotteryWinner function
     */
    address Lottery;

    /**
     * @dev Mapping with key value uint (lottery ticket) leads to the information on ticket
     * amount and time tier for the user to redeem his reward staking.
     */
    mapping(address => bool) lotteryBook;

    /**
     * @dev Modifier ensures only the lottery is allowed to pick new winners
     */
    modifier isLotteryContract {
        require(msg.sender == Lottery);
        _;
    }

    /**
     * @dev Getter function to pull current lottery address
     * @return address of contract
     */
    function getLotteryContract() public view returns (address) {
        return Lottery;
    }

    /**
     * @dev Getter function to pull information on lottery winner
     * @param _userAddress address of user queried
     * @return if user has a multiplier ready to be reedemed
     */
    function lotteryWinner(address _userAddress) public view returns (bool) {
        return (lotteryBook[_userAddress]);
    }

    /**
     * @dev Setter function to change the contract address for the lottery connected to
     * staking.
     * @notice This action can only be perform under dev vote.
     * @param _lotteryAddress address of lottery contract picking winners.
     */
    function setLotteryContract(address _lotteryAddress) public {
        Lottery = _lotteryAddress;
    }

    /**
     * @dev Passes an array of winners
     * @param _winners array of all  winners
     * @notice Only an allowed address will be able to execute this function
     */
    function lottery(address[] memory _winners) public isLotteryContract {
        // needs modifier
        for (uint256 i = 0; i < _winners.length; i++) {
            lotteryBook[_winners[i]] = true;
        }
    }

    // ****************************** Lending **********************************

    // /**
    //  * @dev Mapping with key to store all loan information with the key of borrower address
    //  *  and value of Loan struct with all loan information
    //  */
    // mapping(address => Loan) public loanBook;

    // /**
    //  * @dev Informstion from previously fullfilled loans are stored into the blockchain
    //  * before being permanently deleted
    //  */
    // mapping(address => Loan[]) public loanRecords;
    // /**
    //  * @dev struct to access information on tier structure
    //  */
    // struct loanTier {
    //     uint256 principalLimit;
    //     uint256 maximumPaymentPeriod;
    //     uint256 maxVoters;
    // }

    // mapping(uint256 => loanTier) loanTiers;

    // /**
    //  * @dev Struct to store loan information
    //  */
    // struct Loan {
    //     address borrower; // Address of wallet
    //     uint256 amountBorrowed; // Initial loan balance
    //     uint256 remainingBalance; // Remaining balance
    //     uint256 minimumPayment; // MinimumPayment // Can be calculated off total amount
    //     uint256 collateral; // Amount owed back to borrower after loan is paid in full
    //     bool active; // Is the current loan active (Voted yes)
    //     bool initialized; // Does the borrower have a current loan application
    //     uint256 timeCreated; // Time of loan application also epoch in days
    //     uint256 dueDate; // Time of contract ending
    //     uint256 totalVote; // Total amount determined by tier
    //     uint256 yes; // Amount of votes for yes
    //     // address currentCoin; // Address of collateral coin
    // }

    // /**
    //  * @dev Recalculates interest and also conducts check and balances
    //  */

    // function newLoan(uint256 _paymentPeriod, uint256 _principal)
    //     public
    //     payable
    // {
    //     require(loanBook[msg.sender].initialized == false);

    //     uint256 riskScore = 20; // NFT ENTRY!!!!
    //     uint256 riskFactor = 15; // NFT ENTRY!!!!
    //     uint256 interestRate = 2; // NFT ENTRY!!!!
    //     uint256 userMaxTier = 5; // NFT ENTRY!!!!
    //     // uint256 flatfee = 400; // NFT ENTRY!!!!

    //     require(
    //         _paymentPeriod <= loanTiers[userMaxTier].maximumPaymentPeriod,
    //         "Payment period exceeds that of the tier, pleas try again"
    //     );

    //     // One dollar in ETH
    //     uint256 oneUSDinETH =
    //         SafeMath.div(100000000000000000000, oracle.priceOfETH());

    //     // Calculate how much is being borrowed in USD - must be within limits of the tier
    //     uint256 amountBorrowed = SafeMath.div(_principal, oneUSDinETH);
    //     require(amountBorrowed <= loanTiers[userMaxTier].principalLimit);

    //     // Pay loan application lee to cover for fees
    //     // require(msg.value >= SafeMath.mul(oneUSDinETH,flatfee)); // Needs change based on current prices

    //     (uint256 CBLTprice, uint256 ETHprice, bool ready) =
    //         oracle.priceOfPair(
    //             address(token),
    //             0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    //         );

    //     // Calculate collateral in CBLT based on principal, riskScore and riskFactor
    //     uint256 collateralInCBLT =
    //         SafeMath.div(
    //             SafeMath.multiply(
    //                 _principal,
    //                 SafeMath.mul(riskScore, riskFactor),
    //                 100
    //             ),
    //             CBLTprice
    //         );

    //     // Calculate new principal with the added interest
    //     uint256 finalPrincipal =
    //         SafeMath.add(
    //             _principal,
    //             SafeMath.multiply(_principal, interestRate, 100)
    //         );

    //     uint256 monthlyPayment = SafeMath.div(finalPrincipal, _paymentPeriod);

    //     require(
    //         token.transferFrom(msg.sender, address(this), collateralInCBLT) ==
    //             true,
    //         "Payment was not approved."
    //     );

    //     loanBook[msg.sender] = Loan(
    //         msg.sender,
    //         _principal,
    //         finalPrincipal,
    //         monthlyPayment,
    //         collateralInCBLT,
    //         false,
    //         true,
    //         SafeMath.add(block.timestamp, 2629743),
    //         block.timestamp,
    //         loanTiers[userMaxTier].maxVoters,
    //         0
    //     );
    // }

    // /**
    //  * @dev
    //  */

    // function processPeriod(uint256 _payment, bool _missedPayment) internal {
    //     loanBook[msg.sender].remainingBalance = SafeMath.sub(
    //         loanBook[msg.sender].remainingBalance,
    //         _payment
    //     );

    //     loanBook[msg.sender].dueDate = SafeMath.add(block.timestamp, 2629743);

    //     if (_missedPayment) {
    //         // Needs to interact with the NFT
    //         // Collateral is substracted
    //         // Strike system // Connected to NFT
    //         uint256 daysMissed =
    //             SafeMath.div(
    //                 SafeMath.sub(block.timestamp, loanBook[msg.sender].dueDate),
    //                 86400
    //             );
    //         if (daysMissed > 7) {
    //             // Suspend loan
    //         }
    //     }
    // }

    // /**
    //  * @dev
    //  */
    // function validate() public {} // Only devs

    // /**
    //  * @dev Function for the user to make a payment with ETH
    //  *
    //  */
    // function makePayment() public payable {
    //     require(msg.value >= loanBook[msg.sender].minimumPayment);

    //     if (block.timestamp <= loanBook[msg.sender].dueDate) {
    //         processPeriod(msg.value, false);
    //     } else {
    //         processPeriod(msg.value, true);
    //     }
    // }

    // /**
    //  * @dev
    //  */
    // function returnCollateral() public {
    //     require(loanBook[msg.sender].remainingBalance == 0);

    //     uint256 amount = loanBook[msg.sender].collateral;
    //     require(token.transfer(msg.sender, amount));

    //     loanBook[msg.sender].collateral = 0;
    // }

    // /**
    //  * @dev Deletes loan instance once the user has paid his active loan in full
    //  */
    // function cleanSlate() public {
    //     require(loanBook[msg.sender].remainingBalance == 0);
    //     loanRecords[msg.sender].push(loanBook[msg.sender]);
    //     delete loanBook[msg.sender];
    // }

    // ********************************* Staking ***********************************

    /**
     * @dev Struct saves tier interest, monitor amount of stakers allowed per tier and
     * tier duration used to calculate due dates.
     */
    struct crossTier {
        uint256 interest;
        uint256 amountStakersLeft;
        uint256 tierDuration;
    }

    /**
     * @dev Struct saves user data for ongoing staking and lottery results.
     */
    struct User {
        uint256 ethBalance;
        uint256 tokenReserved;
        uint256 depositTime;
        uint256 timeStakedTier;
        uint256 amountStakedTier;
        address currentTokenStaked;
    }

    /**
     * @dev Variable displays information on ETH staked in the treasury for time tiers 4 and 5.
     */
    uint256 public borrowingPool;

    /**
     * @dev Variable displaying the maximum time tier supported.
     */
    uint256 public tierMax;

    /**
     * @dev Nested mappings with key value uint (time tier) leads to submapping with key value uint
     * (amount tier) that leads the crossTier combination to pull the combination's interest amount of stakers
     * avaliable and the tier duration used to calculate due date period.
     */
    mapping(uint256 => mapping(uint256 => crossTier)) public stakingRewardRate;

    /**
     * @dev Mapping with key value address(the user's address) leads to the struct with the user's
     * staking and lottery information.
     */
    mapping(address => User) public userBook;

    /**
     * @dev Mapping with key value address (user address) leads to submapping with key value address
     * (token address) to pull the current balance rewarded to that user in the tokens
     */
    mapping(address => mapping(address => uint256)) public rewardWallet;

    /**
     * @dev Modifier checks if staking is currently online, the deposit is higher
     * than 0.015 ETH and tier value falls under the supported amount
     */
    modifier isValidStake(uint256 _timeStakedTier) {
        // Checks if staking is currently online
        require(stakingStatus == true, "Staking is currently offline");

        // Minimum deposit of 0.015 ETH
        require(
            msg.value > 15e16,
            "Error, deposit must be higher than 0.015 ETH"
        );

        // The tier input must be between 1 and tierMax
        require(
            _timeStakedTier >= 1 && _timeStakedTier <= tierMax,
            "Tier number must be a number between 1 and maximum tier supported."
        );
        _;
    }

    /**
     * @dev Modifier checks current support on other tokens as rewards for staking
     */
    modifier tokenIsCBLT(address _tokenAddress) {
        if (multipleTokenSupport == false) {
            require(
                _tokenAddress ==
                    address(0x433C6E3D2def6E1fb414cf9448724EFB0399b698),
                "Token must be CBLT"
            );
        }
        _;
    }

    function getEstimateUSD(uint256 _tokenAmount, address _tokenAddress)
        public
        view
        returns (uint256)
    {
        uint256 tokenToETH;
        uint256 ETHtoUSD;
        uint256 ETHprice = oracle.priceOfETH();
        uint256 tokenPrice = oracle.priceOfToken(address(_tokenAddress));
        uint256 ETHinUSD = SafeMath.div(100000000000000000000, ETHprice);

        tokenToETH = SafeMath.mul(_tokenAmount, tokenPrice);
        ETHtoUSD = SafeMath.div(tokenToETH, ETHinUSD);
        return ETHtoUSD;
    }

    /**
     * @dev Getter function pulls current tier information.
     * @param _amount amount value sent in ETH used to access tier combination.
     * @param _timeTier key tier time value used to access tier combination.
     * @return Returns the interest under time and amount tier combination, amount of stakers avaliable.
     * and the tierDuration or period staked in EPOCH.
     */
    function getTierInformation(uint256 _amount, uint256 _timeTier)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountStakedTier;

        if (_amount <= 4e17) {
            amountStakedTier = 1;
        } else if (_amount <= 2e18) {
            amountStakedTier = 2;
        } else if (_amount <= 5e18) {
            amountStakedTier = 3;
        } else if (_amount <= 25e18) {
            amountStakedTier = 4;
        } else {
            amountStakedTier = 5;
        }

        return (
            stakingRewardRate[_timeTier][amountStakedTier].interest,
            stakingRewardRate[_timeTier][amountStakedTier].amountStakersLeft,
            stakingRewardRate[_timeTier][amountStakedTier].tierDuration
        );
    }

    /**
     * @dev
     */
    function getTierCombination(uint256 _amountTier, uint256 _timeTier)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            stakingRewardRate[_timeTier][_amountTier].interest,
            stakingRewardRate[_timeTier][_amountTier].amountStakersLeft,
            stakingRewardRate[_timeTier][_amountTier].tierDuration
        );
    }

    /**
     * @dev Getter function to pull information from the user.
     * @param _userAddress address of the queried user.
     */
    function getUser(address _userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        return (
            userBook[_userAddress].ethBalance,
            userBook[_userAddress].tokenReserved,
            userBook[_userAddress].depositTime,
            userBook[_userAddress].timeStakedTier,
            userBook[_userAddress].amountStakedTier,
            userBook[_userAddress].currentTokenStaked
        );
    }

    /**
     * @dev Getter function to pull avaliable tokens ready to withdraw from reserves
     * @param _userAddress address of queried user
     * @param _tokenAddress address of queried token
     */
    function getUserBalance(address _userAddress, address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return rewardWallet[_userAddress][_tokenAddress];
    }

    /**
     * @dev Setter function to modify interests based on time and amount
     * @notice Function is used to modify existing tiers or create new tiers if new
     * tier key values are passed, creating new tier combinations.If time tier used
     * is higher than current tier max, new tier combination was just created and
     * tierMax should change to new cap
     * @notice This action can only be perform under dev vote
     * @param _amountTier key tier amount value used to access tier combination.
     * @param _timeTier key tier time value used to access tier combination.
     * @param _interest new interest to be modified.
     * @param _amountStakersLeft new interest to be modified.
     * @param _tierDuration new tier duration to be modified.
     */
    function setTierInformation(
        uint256 _amountTier,
        uint256 _timeTier,
        uint256 _interest,
        uint256 _amountStakersLeft,
        uint256 _tierDuration
    ) public {
        require(_amountTier <= 5, "Amount tier must be lower or equal to 5");

        stakingRewardRate[_timeTier][_amountTier].interest = _interest;
        stakingRewardRate[_timeTier][_amountTier]
            .amountStakersLeft = _amountStakersLeft;
        stakingRewardRate[_timeTier][_amountTier].tierDuration = _tierDuration;
        // Check if time tier modified increases the tierMax cap
        if (_timeTier > tierMax) {
            tierMax = _timeTier; // Save new tierMax if so
        }
    }

    function calculateAmountTier(uint256 _amount, uint256 _timeStakedTier)
        internal
        pure
        returns (uint256, uint256)
    {
        uint256 amountStakedTier;
        uint256 paidAdvanced;

        if (_amount <= 4e17) {
            amountStakedTier = 1;
        } else if (_amount <= 2e18) {
            amountStakedTier = 2;
        } else if (_amount <= 5e18) {
            amountStakedTier = 3;
        } else if (_amount <= 25e18) {
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

        return (amountStakedTier, paidAdvanced);
    }

    function calculateFee(uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 newBalance;
        uint256 fee;

        if (_amount > feeThreshold) {
            fee = SafeMath.multiply(_amount, percentFee, 1000);
            newBalance = SafeMath.sub(_amount, fee);
        } else {
            uint256 ETHprice = oracle.priceOfETH();
            uint256 ETHinUSD = SafeMath.div(100000000000000000000, ETHprice);
            fee = SafeMath.mul(ETHinUSD, flatFee);
            newBalance = SafeMath.sub(_amount, fee);
        }

        return (newBalance, fee);
    }

    function calculateRewardReturn(
        uint256 _timeStakedTier,
        uint256 _amountStakedTier,
        uint256 _balance,
        address _tokenAddress
    ) internal view returns (uint256) {
        uint256 dueDate;
        uint256 tokensReserved;

        if (userBook[msg.sender].ethBalance > 0) {
            dueDate = SafeMath.add(
                stakingRewardRate[_timeStakedTier][_amountStakedTier]
                    .tierDuration,
                userBook[msg.sender].depositTime
            );

            require(
                block.timestamp > 1,
                "Current staking period is not over yet"
            );
        }

        tokensReserved = calculateRewardDeposit(
            _balance,
            _timeStakedTier,
            _amountStakedTier,
            _tokenAddress
        );
        return tokensReserved;
    }

    /**
     * @dev Function sends an estimation of how many tokens user is owed
     * @param _amount Amount of ETH send by the user
     * @param _timeStakedTier Duration tier for staking instance
     * @param _tokenAddress Address of token rewarded
     */
    function getTokenReturn(
        uint256 _amount,
        uint256 _timeStakedTier,
        address _tokenAddress
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 fee;
        uint256 tokensOwed;
        uint256 paidAdvanced;
        uint256 amountStakedTier;
        uint256 newBalance =
            SafeMath.add(userBook[msg.sender].ethBalance, _amount);

        (amountStakedTier, paidAdvanced) = calculateAmountTier(
            _amount,
            _timeStakedTier
        );

        (newBalance, fee) = calculateFee(newBalance);

        tokensOwed = calculateRewardReturn(
            _timeStakedTier,
            amountStakedTier,
            newBalance,
            _tokenAddress
        );

        return (tokensOwed, paidAdvanced, newBalance, amountStakedTier);
    }

    /**
     * @dev Function stakes ethereum based on the user's desired duration and token of reward
     * @param _timeStakedTier intended duration of their desired staking period
     * @param _tokenAddress token address rewarded to user staking
     * CBLT used as default during launch
     * @notice Modifier tokenIsCBLT checks if support for other tokens as reward is turned on.
     */
    function stakeEth(uint32 _timeStakedTier, address _tokenAddress)
        public
        payable
        tokenIsCBLT(_tokenAddress)
        isValidStake(_timeStakedTier)
        stakingTermination(false)
    {
        uint256 amountStakedTier;
        uint256 paidAdvanced = 0;
        uint256 tokensReserved;
        uint256 balance;
        uint256 fee;
        uint256 userReserved = userBook[msg.sender].tokenReserved;

        if (userReserved > 0) {
            payRewardWallet(userReserved);
        }

        (
            tokensReserved,
            paidAdvanced,
            balance,
            amountStakedTier
        ) = getTokenReturn(msg.value, _timeStakedTier, _tokenAddress);

        require(
            tokensReserved <= tokenReserve[_tokenAddress],
            "Treasury is currently depleted"
        );

        if (paidAdvanced > 0) {
            uint256 tokensSent =
                SafeMath.multiply(tokensReserved, paidAdvanced, 100);
            // IERC20(_tokenAddress).universalTransfer(msg.sender, tokensSent);

            userBook[msg.sender].tokenReserved = SafeMath.add(
                userBook[msg.sender].tokenReserved,
                SafeMath.sub(tokensReserved, tokensSent)
            );
        } else {
            userBook[msg.sender].tokenReserved = SafeMath.add(
                userBook[msg.sender].tokenReserved,
                tokensReserved
            );
        }

        if (!lotteryBook[msg.sender]) {
            require(
                stakingRewardRate[_timeStakedTier][amountStakedTier]
                    .amountStakersLeft > 0,
                "Tier depleted, come back later"
            );

            stakingRewardRate[_timeStakedTier][amountStakedTier]
                .amountStakersLeft = SafeMath.sub(
                stakingRewardRate[_timeStakedTier][amountStakedTier]
                    .amountStakersLeft,
                1
            );
        }

        userBook[msg.sender].timeStakedTier = _timeStakedTier;
        userBook[msg.sender].amountStakedTier = amountStakedTier;
        userBook[msg.sender].currentTokenStaked = _tokenAddress;
        userBook[msg.sender].depositTime = block.timestamp;
        userBook[msg.sender].ethBalance = balance;

        totalFeeBalance = SafeMath.add(totalFeeBalance, fee);
        tokenReserve[_tokenAddress] = SafeMath.sub(
            tokenReserve[_tokenAddress],
            tokensReserved
        );
    }

    /**
     * @dev Helper function calculates amount of tokens owed to user at current market value
     * with both tier combinations. If user is restaking the function calls another helper
     * function (payRewardWalletDeposit(userReserved)) that deposits previous tokens staked
     * this function also recalculates the amount based on deposit and current token value.
     * @param _amount new amount balance saved by user. Combination of existing balance and
     * incoming amount.
     * @param _timeStakedTier time duration tier for staking period
     * @param _amountStakedTier time amount tier for staking period
     * @param _tokenAddress token address of token owed at the end of staking period
     * be rewarded with x2 interest reward for his staking period
     */
    function calculateRewardDeposit(
        uint256 _amount,
        uint256 _timeStakedTier,
        uint256 _amountStakedTier,
        address _tokenAddress
    ) internal view returns (uint256) {
        uint256 tokenPrice = oracle.priceOfToken(address(_tokenAddress));
        uint256 interest;

        if (lotteryBook[msg.sender]) {
            interest = SafeMath.mul(
                stakingRewardRate[_timeStakedTier][_amountStakedTier].interest,
                2
            );
        } else {
            interest = stakingRewardRate[_timeStakedTier][_amountStakedTier]
                .interest;
        }

        return
            SafeMath.mul(
                SafeMath.div(
                    SafeMath.multiply(_amount, interest, 100),
                    tokenPrice
                ),
                1e18
            );
    }

    /**
     * @dev Helper function calculates the amount of tokens owed to user based on previous
     * token value, time and amount tier combination and current token value and saves the
     * amount in the virtual wallet for the user to withdraw from.
     * @notice if the new amount promised to user is higher than avaliable for a lottery winner
     * treasury will check if we can fund the reward. If not, lottery ticket is saved for another
     * instance
     * @param _userReserved maximum amount of tokens reserved for user based on previous
     * token value when staking instance was created.
     */
    function payRewardWallet(uint256 _userReserved) internal {
        uint256 interest;
        uint256 percentBasedAmount = 100;
        uint256 amountStakedPreviously = userBook[msg.sender].ethBalance;
        uint256 previousTimeTier = userBook[msg.sender].timeStakedTier;
        uint256 previousAmountTier = userBook[msg.sender].amountStakedTier;
        address previousTokenAddress = userBook[msg.sender].currentTokenStaked;
        uint256 previousTokenPrice = oracle.priceOfToken(previousTokenAddress);

        if (
            previousTimeTier == 4 &&
            (previousAmountTier == 4 || previousAmountTier == 5)
        ) {
            percentBasedAmount = 75;
        } else if (
            previousTimeTier == 5 &&
            (previousAmountTier == 4 || previousAmountTier == 5)
        ) {
            percentBasedAmount = 50;
        }

        if (lotteryBook[msg.sender]) {
            interest = SafeMath.mul(
                stakingRewardRate[userBook[msg.sender].timeStakedTier][
                    previousAmountTier
                ]
                    .interest,
                2
            );
        } else {
            interest = stakingRewardRate[userBook[msg.sender].timeStakedTier][
                previousAmountTier
            ]
                .interest;
        }

        uint256 tokensOwed =
            SafeMath.mul(
                SafeMath.div(
                    SafeMath.multiply(
                        SafeMath.multiply(
                            amountStakedPreviously,
                            percentBasedAmount,
                            100
                        ),
                        interest,
                        100
                    ),
                    previousTokenPrice
                ),
                1e18
            );

        if (tokensOwed >= _userReserved) {
            if (lotteryBook[msg.sender]) {
                if (tokensOwed < tokenReserve[previousTokenAddress]) {
                    tokenReserve[previousTokenAddress] = SafeMath.sub(
                        tokenReserve[previousTokenAddress],
                        tokensOwed
                    );
                    rewardWallet[msg.sender][previousTokenAddress] = SafeMath
                        .add(
                        rewardWallet[msg.sender][previousTokenAddress],
                        tokensOwed
                    );

                    lotteryBook[msg.sender] = false;
                } else {
                    rewardWallet[msg.sender][previousTokenAddress] = SafeMath
                        .add(
                        rewardWallet[msg.sender][previousTokenAddress],
                        _userReserved
                    );
                }
            } else {
                rewardWallet[msg.sender][previousTokenAddress] = SafeMath.add(
                    rewardWallet[msg.sender][previousTokenAddress],
                    _userReserved
                );

                stakingRewardRate[previousTimeTier][previousAmountTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[previousTimeTier][previousAmountTier]
                        .amountStakersLeft,
                    1
                );
            }
            userBook[msg.sender].tokenReserved = 0;
        } else {
            uint256 tokenDifference = SafeMath.sub(_userReserved, tokensOwed);

            tokenReserve[previousTokenAddress] = SafeMath.add(
                tokenReserve[previousTokenAddress],
                tokenDifference
            );

            rewardWallet[msg.sender][previousTokenAddress] = SafeMath.add(
                rewardWallet[msg.sender][previousTokenAddress],
                tokensOwed
            );

            userBook[msg.sender].tokenReserved = 0;

            if (!lotteryBook[msg.sender]) {
                stakingRewardRate[previousTimeTier][previousAmountTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[previousTimeTier][previousAmountTier]
                        .amountStakersLeft,
                    1
                );
                lotteryBook[msg.sender] = false;
            }
        }
    }

    /**
     * @dev Function sends a specified amount of ETH from the users balance back to the user
     * @notice Function also allocates final amount tokens owed into users reward wallet
     * if this hasnt ocurred already
     */
    function withdrawEth(uint256 _amount)
        public
        payable
        stakingTermination(false)
    {
        uint256 dueDate;
        uint256 userReserved = userBook[msg.sender].tokenReserved;
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier = userBook[msg.sender].amountStakedTier;
        uint256 userBalance = userBook[msg.sender].ethBalance;

        // if (userReserved > 0) {
        //     payRewardWallet(userReserved);
        // }

        dueDate = SafeMath.add(
            stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                .tierDuration,
            userBook[msg.sender].depositTime
        );

        require(block.timestamp >= 1, "Staking period is not over.");

        userBook[msg.sender].ethBalance = SafeMath.sub(userBalance, _amount);

        payable(msg.sender).transfer(_amount);
    }

    /**
     * @dev Function transfer an amount of desired cblt tokens from the user's
     * token reward wallet.
     * @notice Function also calculates any running token balance reserved and deposits it
     * on the user's reward wallet
     * @param _amount amount of token rewarded sent to the user's wallet
     * @param _withdrawTokenAddress token address of token being withdrawn
     */
    function withdrawStaking(uint256 _amount, address _withdrawTokenAddress)
        public
        payable
        stakingTermination(false)
    {
        uint256 dueDate;
        uint256 userReserved = userBook[msg.sender].tokenReserved;
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier = userBook[msg.sender].amountStakedTier;

        if (userReserved > 0) {
            dueDate = SafeMath.add(
                stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                    .tierDuration,
                userBook[msg.sender].depositTime
            );

            require(
                1 < block.timestamp,
                "Current staking period is still active"
            );

            payRewardWallet(userReserved);
        }

        (uint256 tokenPrice, uint256 ETHprice) =
            oracle.priceOfETHandCBLT(_withdrawTokenAddress);

        uint256 USDtoToken =
            SafeMath.multiply(
                SafeMath.div(1000000000000000000, tokenPrice),
                SafeMath.div(100000000000000000000, ETHprice),
                1000000000000000000
            );

        require(
            SafeMath.mul(USDtoToken, 5) > 50,
            "Amount in CBLT must be higher than 50 total worth in value."
        );

        rewardWallet[msg.sender][_withdrawTokenAddress] = SafeMath.sub(
            rewardWallet[msg.sender][_withdrawTokenAddress],
            _amount
        );

        // IERC20(_withdrawTokenAddress).universalTransfer(msg.sender, _amount);
    }

    /**
     * @dev Breaks staking instance for users with a duration tier higher than
     * the default of 5. A relative amount of tokens reserved are sent to the
     * user based on time staked.
     */
    function earlyWithdraw() public payable stakingTermination(false) {
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier = userBook[msg.sender].amountStakedTier;
        address previousTokenAddress = userBook[msg.sender].currentTokenStaked;
        uint256 timeOfStaking = userBook[msg.sender].depositTime;
        uint256 userBalance = userBook[msg.sender].ethBalance;
        uint256 tokensReserved = userBook[msg.sender].tokenReserved;

        require(stakingPeriodTier > 5, "Tier not supporting early withdraw");

        uint256 timeStaked = SafeMath.sub(block.timestamp, timeOfStaking);
        uint256 tokenPrice = oracle.priceOfToken(previousTokenAddress);

        uint256 tokensOwed =
            SafeMath.mul(
                SafeMath.div(
                    SafeMath.multiply(
                        userBalance,
                        stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                            .interest,
                        100
                    ),
                    tokenPrice
                ),
                1e18
            );

        uint256 relativeOwed =
            SafeMath.multiply(
                tokensOwed,
                timeStaked,
                stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                    .tierDuration
            );

        // Reset values
        userBook[msg.sender].ethBalance = 0;
        userBook[msg.sender].tokenReserved = 0;
        userBook[msg.sender].depositTime = block.timestamp;

        if (relativeOwed > tokensReserved) {
            // IERC20(previousTokenAddress).universalTransfer(
            //     msg.sender,
            //     tokensReserved
            // );
        } else {
            // IERC20(previousTokenAddress).universalTransfer(
            //     msg.sender,
            //     relativeOwed
            // );
        }

        payable(msg.sender).transfer(userBalance);
    }

    /**
     * @dev Function allows all users to break staking instance and withdraw
     * all eth deposited for staking.
     */
    function emergencyWithdraw() public payable stakingTermination(true) {
        uint256 userBalance = userBook[msg.sender].ethBalance;

        // Substract eth from user account
        userBook[msg.sender].ethBalance = 0;

        payable(msg.sender).transfer(userBalance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
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

//     "4": {
//       "events": {},
//       "links": {},
//       "address": "0xb46dc6f708711a9887d6f4260e27e46cc77ac7a9",
//       "transactionHash": "0xe4cd16d654f7c2b00579515b007587830bfb922e3bd3307850b15d953b9a49f4"
//     }
