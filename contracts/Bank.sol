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

        // Time tier at launch is 5
        tierMax = 5;
        // Assing value to other token support
        multipleTokenSupport = false;
        // Assign value to staking status
        stakingStatus = true;
        // Assign value to fee
        fee = 3;
        // Assign value to terminateStaking
        terminateStaking = false;

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
     * @dev Events emitted
     */
    event onReceived(address indexed _from, uint256 _amount);
    event onTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );
    event depositToken(address indexed _from, uint256 _amount);

    // **************************************** DEV VOTE ************************************************

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

    // Adds a new developer to the devArray
    function addDevTeam(address _dev) public {
        devArray.push(_dev);
    }
    
    // Function used to delete a member from the devArray
    // Slightly more inefficient, but it completely removes the member from the devArray
    // Need to test: Make sure it only deletes if the param is within the length of devArray
    function deleteDevTeam(uint index) public {
        for(uint i = index; i < devArray.length - 1; i++) {
            devArray[i] = devArray[i+1];
        }
        devArray.pop();
    }
    
    // "Deletes" developer from array by changing their address to a zero address
    // Cheaper/faster but it leaves the zero address in the array (length does not change)
    // Need to test: Figure out how to reduce length even when the address is not removed
    function modifyDevTeam(uint256 index) public {
        devArray[index] = address(0);
    }
    
    // Displays the contents of devArray
    // Used for testing
    function displayDevArray() external view returns (address[] memory){
        return devArray;
    }
    
    // Displays the length of devArray
    // Used for testing
    function displayDevLength() external view returns (uint256) {
        return devArray.length;
    }
    
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

    /**
     * @dev Mapping with key value address (token address) leads the current reserves avaliable for tokens
     * being currently offered to stake on.
     */
    mapping(address => uint256) public tokenReserve;

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
     * @dev Variable displays information on ETH staked in the treasury for time tiers 4 and 5.
     */
    uint256 public borrowingPool;

    /**
     * @dev Getter function to pull total amount of ETH saved in fees
     */
    function getFees() public view returns (uint256) {
        return totalFeeBalance;
    }

    /**
     * @dev Variable displaying the maximum time tier supported.
     */
    uint256 public tierMax;

    /**
     * @dev Bool switch for all staking instance terminations
     */
    bool public terminateStaking;

    /**
     * @dev Function terminates all staking instances and allows early balance withdrewal
     * @param _bool true terminates all contract instances and allows users to withdraw
     * @notice This action can only be perform under dev vote.
     */
    function setStakingTermination(bool _bool) public {
        terminateStaking = _bool;
    }

    /**
     * @dev Bool switch turns support for other tokens as reward outside of CBLT.
     */
    bool multipleTokenSupport;

    /**
     * @dev Setter function to turn support for other tokens.
     * @notice This action can only be perform under dev vote.
     * @param _bool true turns on other token support for staking reward, false off
     */
    function setTokenSupport(bool _bool) public {
        multipleTokenSupport = _bool;
    }

    /**
     * @dev Getter function to pull info on support for other tokens.
     */
    function getTokenSupport() public view returns (bool) {
        return multipleTokenSupport;
    }

    /**
     * @dev Variable to turn staking off and on.
     */
    bool public stakingStatus;

    /**
     * @dev Setter function to turn staking status on and off.
     * @notice This action can only be perform under dev vote.
     * @param _bool value true - on, false - off.
     */
    function setStakingStatus(bool _bool) public {
        stakingStatus = _bool;
    }

    /**
     * @dev Getter function to pull staking status on and off.
     */
    function getStakingStatus() public view returns (bool) {
        return stakingStatus;
    }

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
     * @dev Nested mappings with key value uint (time tier) leads to submapping with key value uint
     * (amount tier) that leads the crossTier combination to pull the combination's interest amount of stakers
     * avaliable and the tier duration used to calculate due date period.
     */
    mapping(uint256 => mapping(uint256 => crossTier)) public stakingRewardRate;

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

    /**
     * @dev Struct saves user data for ongoing staking and lottery results.
     */
    struct User {
        uint256 ethBalance;
        uint256 tokenReserved;
        uint256 depositTime;
        uint256 timeStakedTier;
        address currentTokenStaked;
        uint256 lotteryTicket;
        bool withdrawReady;
    }

    /**
     * @dev Mapping with key value address(the user's address) leads to the struct with the user's
     * staking and lottery information.
     */
    mapping(address => User) public userBook;

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
            address,
            uint256,
            bool
        )
    {
        return (
            userBook[_userAddress].ethBalance,
            userBook[_userAddress].tokenReserved,
            userBook[_userAddress].depositTime,
            userBook[_userAddress].timeStakedTier,
            userBook[_userAddress].currentTokenStaked,
            userBook[_userAddress].lotteryTicket,
            userBook[_userAddress].withdrawReady
        );
    }

    /**
     * @dev Mapping with key value address (user address) leads to submapping with key value address
     * (token address) to pull the current balance rewarded to that user in the tokens
     */
    mapping(address => mapping(address => uint256)) public rewardWallet;

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
     * @dev Function sends an estimation of how many tokens
     * @param _amount Amount of ETH send by the user
     * @param _timeStakedTier Duration tier for staking instance
     * @param _tokenAddress Address of token rewarded
     */
    function getTokenReturn(
        uint256 _amount,
        uint256 _timeStakedTier,
        address _tokenAddress,
        address _user
    ) public view returns (uint256, uint256) {
        uint256 tokenPrice = oracle.priceOfToken(address(_tokenAddress));
        uint256 lotteryTicket = userBook[_user].lotteryTicket;
        uint256 interest;
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
            // if user is staking for 180, pay tokens in advance
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
            }
        } else {
            amountStakedTier = 5;
            // if user is staking for 180, pay tokens in advance
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
            }
        }

        // Checks if the transaction should be charged using a flat or percentage based fee
        if (_amount > 5e18) {
            _amount = SafeMath.sub(
                _amount,
                SafeMath.multiply(_amount, 3, 1000)
            );
        } else {
            // Oracle call for current ETH price in USD
            uint256 ETHprice = oracle.priceOfETH();
            // Dollar fee based
            uint256 ETHinUSD = SafeMath.div(300000000000000000000, ETHprice);
            // New balance saved
            _amount = SafeMath.sub(_amount, SafeMath.mul(ETHinUSD, fee));
        }

        // Calculate and return new CBLT reserved
        if (lotteryTicket > 0) {
            if (userBook[_user].withdrawReady == false) {
                interest = SafeMath.mul(
                    stakingRewardRate[_timeStakedTier][amountStakedTier]
                        .interest,
                    2
                );
            }
            userBook[_user].withdrawReady == true;
        } else {
            interest = stakingRewardRate[_timeStakedTier][amountStakedTier]
                .interest;
        }

        return (
            SafeMath.div(SafeMath.multiply(_amount, interest, 100), tokenPrice),
            paidAdvanced
        );
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
        uint256 amountStakedTier; // Amount tier staked sent as value
        uint256 paidAdvanced = 0; // User sent tokens upfront?
        uint256 dueDate; // Due date to check if user is allowed to restake
        uint256 tokensReserved; // Tokens owed for staking amount
        uint256 balance; // Balance saved after fee is subtracted

        // Checks if the transaction should be charged using a flat or percentage based fee
        if (msg.value > 5e18) {
            balance = SafeMath.sub(
                msg.value,
                SafeMath.multiply(msg.value, 3, 1000)
            );
            totalFeeBalance = SafeMath.sub(msg.value, balance);
        } else {
            // Oracle call for current ETH price in USD
            uint256 ETHprice = oracle.priceOfETH();
            // Dollar fee based
            uint256 ETHinUSD = SafeMath.div(300000000000000000000, ETHprice);
            // New balance saved
            balance = SafeMath.sub(msg.value, SafeMath.mul(ETHinUSD, fee));
            totalFeeBalance = SafeMath.sub(msg.value, balance);
        }

        // Check the amountStakedTier based on deposit
        if (msg.value <= 4e17) {
            amountStakedTier = 1;
        } else if (msg.value <= 2e18) {
            amountStakedTier = 2;
        } else if (msg.value <= 5e18) {
            amountStakedTier = 3;
        } else if (msg.value <= 25e18) {
            amountStakedTier = 4;
            // if user is staking for 180, pay tokens in advance
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
                borrowingPool = SafeMath.add(borrowingPool, balance);
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
                borrowingPool = SafeMath.add(borrowingPool, balance);
            }
        } else {
            amountStakedTier = 5;
            // if user is staking for 180, pay tokens in advance
            if (_timeStakedTier == 4) {
                paidAdvanced = 25;
                borrowingPool = SafeMath.add(borrowingPool, balance);
            } else if (_timeStakedTier == 5) {
                paidAdvanced = 50;
                borrowingPool = SafeMath.add(borrowingPool, balance);
            }
        }

        // Checking if user has a running balance from previous staking instances
        if (userBook[msg.sender].ethBalance > 0) {
            // Creates a due date for current staking period
            dueDate = SafeMath.add(
                stakingRewardRate[_timeStakedTier][amountStakedTier]
                    .tierDuration,
                userBook[msg.sender].depositTime
            );
            // Revert if staking period is not over
            require(
                block.timestamp > 1, //MUST CHANGE BEFORE LAUNCH!!!!!!!!!!!!
                "Current staking period is not over yet"
            );

            // Checks the amount of CBLT tokens that needs to be reserved plus existing balance
            tokensReserved = calculateRewardDeposit(
                SafeMath.add(balance, userBook[msg.sender].ethBalance),
                _timeStakedTier,
                amountStakedTier,
                _tokenAddress
            );
        } else {
            // Calculate the amount of CBLT tokens that need to be reserved
            tokensReserved = calculateRewardDeposit(
                balance,
                _timeStakedTier,
                amountStakedTier,
                _tokenAddress
            );
        }

        // Allow lottery winners to stake in any closed tier
        if (!lotteryBook[msg.sender]) {
            // Check if the tier is currently depleted
            require(
                stakingRewardRate[_timeStakedTier][amountStakedTier]
                    .amountStakersLeft > 0,
                "Tier depleted, come back later"
            );
        }

        // Treasury must have that amount open
        require(
            tokensReserved <= tokenReserve[_tokenAddress],
            "Treasury is currently depleted"
        );

        // Check if we are sending CBLT based on time staked
        if (paidAdvanced > 0) {
            uint256 tokensSent =
                SafeMath.multiply(tokensReserved, paidAdvanced, 100);
            // require( token.transfer(msg.sender, cbltSent), "Transaction was not successful" );

            // Saves the amount of CBLT tokens reserved minus the amount sent in advanced
            userBook[msg.sender].tokenReserved = SafeMath.add(
                userBook[msg.sender].tokenReserved,
                SafeMath.multiply(
                    tokensReserved,
                    SafeMath.sub(100, paidAdvanced),
                    100
                )
            );
        } else {
            // Saves the amount of CBLT tokens reserved in user struct
            userBook[msg.sender].tokenReserved = SafeMath.add(
                userBook[msg.sender].tokenReserved,
                tokensReserved
            );
        }

        // Save amount of time staked
        userBook[msg.sender].timeStakedTier = _timeStakedTier;

        // Substract CBLT tokens reserved for user from treasury
        tokenReserve[_tokenAddress] = SafeMath.sub(
            tokenReserve[_tokenAddress],
            tokensReserved
        );

        // Save new eth deposit in user account
        userBook[msg.sender].ethBalance = SafeMath.add(
            userBook[msg.sender].ethBalance,
            balance
        );

        // Decrease number of stakers avaliable for current tier based on time and amount
        stakingRewardRate[_timeStakedTier][amountStakedTier]
            .amountStakersLeft = SafeMath.sub(
            stakingRewardRate[_timeStakedTier][amountStakedTier]
                .amountStakersLeft,
            1
        );

        // Save token address for user
        userBook[msg.sender].currentTokenStaked = _tokenAddress;

        // Change the time of deposit
        userBook[msg.sender].depositTime = block.timestamp;
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
    ) internal returns (uint256) {
        uint256 tokenPrice = oracle.priceOfToken(address(_tokenAddress));
        uint256 userReserved = userBook[msg.sender].tokenReserved;
        uint256 interest;

        // Check if user has CBLT tokens reserved
        if (userReserved > 0) {
            payRewardWalletDeposit(userReserved);
        }

        // Check lottery status
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
            SafeMath.div(SafeMath.multiply(_amount, interest, 100), tokenPrice);
    }

    /**
     * @dev Helper function calculates the amount of tokens owed to user based on previous
     * token value, time and amount tier combination and current token value and saves the
     * amount in the virtual wallet for the user to withdraw from.
     * @param _userReserved maximum amount of tokens reserved for user based on previous
     * token value when staking instance was created.
     */
    function payRewardWalletDeposit(uint256 _userReserved) internal {
        uint256 interest; // Previous interest
        // Amount tier used in last staking instance
        uint256 amountStakedPreviously = userBook[msg.sender].ethBalance;
        // Time tier used in last staking instance
        uint256 previousTimeTier = userBook[msg.sender].timeStakedTier;
        // The address of the token owed to user for staking
        address previousTokenAddress = userBook[msg.sender].currentTokenStaked;
        // Current price of that token
        uint256 previousTokenPrice = oracle.priceOfToken(previousTokenAddress);
        // Function checks if the user was sent tokens upfront
        (uint256 percentBasedAmount, uint256 previousAmountTier) =
            previousStakingMath(amountStakedPreviously);

        // If user has an active staking period under lottery ticket, tokens owed are doubled
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

        // Calculate the new amount of cblt reserved for user at current market price
        uint256 tokensOwed =
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
            );
        // if new amount owed is larger send all avaliable tokens reserved to user
        if (tokensOwed >= _userReserved) {
            if (lotteryBook[msg.sender]) {
                // Check if treasury can allocate the tokens after multiplier is applied
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
                    // Return lottery value to false after multiplier is used
                    lotteryBook[msg.sender] = false;
                } else {
                    rewardWallet[msg.sender][previousTokenAddress] = SafeMath
                        .add(
                        rewardWallet[msg.sender][previousTokenAddress],
                        _userReserved
                    );
                    // Lottery multipler won't be used if user did not cash out rewards
                }
            } else {
                rewardWallet[msg.sender][previousTokenAddress] = SafeMath.add(
                    rewardWallet[msg.sender][previousTokenAddress],
                    _userReserved
                );

                // Increase number of stakers avaliable for current tier based on time and amount
                stakingRewardRate[previousTimeTier][previousAmountTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[previousTimeTier][previousAmountTier]
                        .amountStakersLeft,
                    1
                );
            }
            userBook[msg.sender].tokenReserved = 0;
        } else {
            // if new amount owed is smaller, calculate the difference between
            // new and old amount owed
            uint256 tokenDifference = SafeMath.sub(_userReserved, tokensOwed);

            // Add lefover tokens back into treasury
            tokenReserve[previousTokenAddress] = SafeMath.add(
                tokenReserve[previousTokenAddress],
                tokenDifference
            );

            // Save tokens in contract wallet
            rewardWallet[msg.sender][previousTokenAddress] = SafeMath.add(
                rewardWallet[msg.sender][previousTokenAddress],
                tokensOwed
            );
            // Reset amount of tokens owed
            userBook[msg.sender].tokenReserved = 0;

            // Increase number of stakers avaliable for current tier based on time and amount
            if (!lotteryBook[msg.sender]) {
                stakingRewardRate[previousTimeTier][previousAmountTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[previousTimeTier][previousAmountTier]
                        .amountStakersLeft,
                    1
                );
            }

            // Return lottery value to false after multiplier is used
            lotteryBook[msg.sender] = false;
        }
    }

    /**
     * @dev Helper function to determine if user was sent tokens upfront based on
     * tier combination during the previous staking instance
     * @param _amountStakedPreviously the amount balance staked previously
     */
    function previousStakingMath(uint256 _amountStakedPreviously)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 previousAmountTier;
        uint256 tierStakedPreviously = userBook[msg.sender].timeStakedTier;
        uint256 percentBasedAmount;

        // Determine the amount staked tier based on ETH balance
        if (_amountStakedPreviously <= 4e17) {
            previousAmountTier = 1;
        } else if (_amountStakedPreviously <= 2e18) {
            previousAmountTier = 2;
        } else if (_amountStakedPreviously <= 5e18) {
            previousAmountTier = 3;
        } else if (_amountStakedPreviously <= 25e18) {
            previousAmountTier = 4;
            if (tierStakedPreviously == 4) {
                percentBasedAmount = 75;
            } else if (tierStakedPreviously == 5) {
                percentBasedAmount = 50;
            }
        } else {
            previousAmountTier = 5;
            if (tierStakedPreviously == 4) {
                percentBasedAmount = 75;
            } else if (tierStakedPreviously == 5) {
                percentBasedAmount = 50;
            }
        }

        return (percentBasedAmount, previousAmountTier);
    }

    /**
     * @dev Helper function to determine if the user is owed tokens during his
     * withdraw instance.
     * @param _timeStakedTier time staked tier of previous staking instance
     * @param _amountStakedTier amount staked tier of previous staking instance
     */
    function payRewardWalletWithdraw(
        uint256 _timeStakedTier,
        uint256 _amountStakedTier,
        uint256 _userReserved
    ) internal {
        uint256 percentBasedAmount = 100;
        address previousTokenAddress = userBook[msg.sender].currentTokenStaked;
        uint256 tokenPrice = oracle.priceOfToken(previousTokenAddress);
        uint256 interest;

        // If user has CBLT tokens reserved on withdraw, calculate how much is owed to him
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
        // Checks if user's lottery ticket is ready to be applied to tokens reserved
        if (lotteryBook[msg.sender]) {
            interest = SafeMath.mul(
                stakingRewardRate[_timeStakedTier][_amountStakedTier].interest,
                2
            );
        } else {
            interest = stakingRewardRate[_timeStakedTier][_amountStakedTier]
                .interest;
        }

        // Calculate new amount of cblt reserved for user at current market price
        uint256 tokensOwed =
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
                tokenPrice
            );

        if (tokensOwed >= _userReserved) {
            if (lotteryBook[msg.sender]) {
                // Check if treasury can allocate the tokens after multiplier is applied
                if (tokensOwed < tokenReserve[previousTokenAddress]) {
                    tokenReserve[previousTokenAddress] = SafeMath.sub(
                        tokenReserve[previousTokenAddress],
                        tokensOwed
                    );
                    // Return lottery value to false after multiplier is used
                    lotteryBook[msg.sender] = false;

                    // Save reward in wallet if any is owed
                    rewardWallet[msg.sender][
                        userBook[msg.sender].currentTokenStaked
                    ] = SafeMath.add(
                        rewardWallet[msg.sender][
                            userBook[msg.sender].currentTokenStaked
                        ],
                        tokensOwed
                    );

                    // Reset amount of CBLT reserved
                    userBook[msg.sender].tokenReserved = 0;
                } else {
                    // Save reward in wallet if any is owed
                    rewardWallet[msg.sender][
                        userBook[msg.sender].currentTokenStaked
                    ] = SafeMath.add(
                        rewardWallet[msg.sender][
                            userBook[msg.sender].currentTokenStaked
                        ],
                        _userReserved
                    );
                    // Reset amount of CBLT reserved
                    userBook[msg.sender].tokenReserved = 0;

                    // Lottery multipler won't be used if user did not cash out rewards
                }
            } else {
                // Increase number of stakers avaliable for current tier based on time and amount
                stakingRewardRate[_timeStakedTier][_amountStakedTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[_timeStakedTier][_amountStakedTier]
                        .amountStakersLeft,
                    1
                );
                // Save reward in wallet if any is owed
                rewardWallet[msg.sender][
                    userBook[msg.sender].currentTokenStaked
                ] = SafeMath.add(
                    rewardWallet[msg.sender][
                        userBook[msg.sender].currentTokenStaked
                    ],
                    _userReserved
                );

                // Reset amount of CBLT reserved
                userBook[msg.sender].tokenReserved = 0;
            }
        } else {
            // Calculate the difference between new and old amount owed
            uint256 tokenDifference = SafeMath.sub(_userReserved, tokensOwed);

            // Add lefover cblt tokens back into treasury
            tokenReserve[previousTokenAddress] = SafeMath.add(
                tokenReserve[previousTokenAddress],
                tokenDifference
            );
            if (!lotteryBook[msg.sender]) {
                // Increase number of stakers avaliable for current tier based on time and amount
                stakingRewardRate[_timeStakedTier][_amountStakedTier]
                    .amountStakersLeft = SafeMath.add(
                    stakingRewardRate[_timeStakedTier][_amountStakedTier]
                        .amountStakersLeft,
                    1
                );
            }
            // Save reward in wallet if any is owed
            rewardWallet[msg.sender][
                userBook[msg.sender].currentTokenStaked
            ] = SafeMath.add(
                rewardWallet[msg.sender][
                    userBook[msg.sender].currentTokenStaked
                ],
                tokensOwed
            );

            // Reset amount of CBLT reserved
            userBook[msg.sender].tokenReserved = 0;
        }
    }

    /**
     * @dev Function sends a specified amount of ETH from the users balance back to the user
     * @notice Function also allocates final amount tokens owed into users reward wallet
     * if this hasnt ocurred already
     * @param _amount amount intended to withdraw
     */
    function withdrawEth(uint256 _amount) public stakingTermination(false) {
        uint256 dueDate;
        uint256 userReserved = userBook[msg.sender].tokenReserved;
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier;
        uint256 userBalance = userBook[msg.sender].ethBalance;

        // Determine the amount staked tier based on ETH balance
        if (userBalance <= 4e17) {
            stakingAmountTier = 1;
        } else if (userBalance <= 2e18) {
            stakingAmountTier = 2;
        } else if (userBalance <= 5e18) {
            stakingAmountTier = 3;
        } else if (userBalance <= 25e18) {
            stakingAmountTier = 4;
        } else {
            stakingAmountTier = 5;
        }

        // Calulate due date based on time staked tier and deposit time
        dueDate = SafeMath.add(
            stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                .tierDuration,
            userBook[msg.sender].depositTime
        );

        // Staking period must be over before he withdraws ETH balance
        require(block.timestamp >= 1, "Staking period is not over."); // MUST CHANGE

        if (userReserved > 0) {
            payRewardWalletWithdraw(
                stakingPeriodTier,
                stakingAmountTier,
                userReserved
            );
        }

        // Substract eth from user account
        userBook[msg.sender].ethBalance = SafeMath.sub(
            userBook[msg.sender].ethBalance,
            _amount
        );

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
        uint256 dueDate; // Due date to check if user is allowed to restake
        uint256 userReserved = userBook[msg.sender].tokenReserved;
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier;
        uint256 userBalance = userBook[msg.sender].ethBalance;

        // Determine the amount staked tier based on ETH balance
        if (userBalance <= 4e17) {
            stakingAmountTier = 5;
        } else if (userBalance <= 2e18) {
            stakingAmountTier = 4;
        } else if (userBalance <= 5e18) {
            stakingAmountTier = 3;
        } else if (userBalance <= 25e18) {
            stakingAmountTier = 2;
        } else {
            stakingAmountTier = 1;
        }

        if (userReserved > 0) {
            // Creates a due date for current staking period
            dueDate = SafeMath.add(
                stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                    .tierDuration,
                userBook[msg.sender].depositTime
            );
            // Check if user has an ongoing staking instance
            if (block.timestamp < 1) {
                payRewardWalletDeposit(userReserved);
            } else {
                payRewardWalletWithdraw(
                    stakingPeriodTier,
                    stakingAmountTier,
                    userReserved
                );
            }
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

        // token.transfer
    }

    /**
     * @dev Breaks staking instance for users with a duration tier higher than
     * the default of 5. A relative amount of tokens reserved are sent to the
     * user based on time staked.
     */
    function earlyWithdraw() public payable stakingTermination(false) {
        uint256 stakingPeriodTier = userBook[msg.sender].timeStakedTier;
        uint256 stakingAmountTier;
        address previousTokenAddress = userBook[msg.sender].currentTokenStaked;
        uint256 timeOfStaking = userBook[msg.sender].depositTime;
        uint256 userBalance = userBook[msg.sender].ethBalance;

        require(stakingPeriodTier > 5, "Tier not supporting early withdraw");

        // Determine the amount staked tier based on ETH balance
        if (userBalance <= 4e17) {
            stakingAmountTier = 1;
        } else if (userBalance <= 2e18) {
            stakingAmountTier = 2;
        } else if (userBalance <= 5e18) {
            stakingAmountTier = 3;
        } else if (userBalance <= 25e18) {
            stakingAmountTier = 4;
        } else {
            stakingAmountTier = 5;
        }

        uint256 timeStaked = SafeMath.sub(block.timestamp, timeOfStaking);

        uint256 tokenPrice = oracle.priceOfToken(previousTokenAddress);

        uint256 tokensOwed =
            SafeMath.div(
                SafeMath.multiply(
                    userBalance,
                    stakingRewardRate[stakingPeriodTier][stakingAmountTier]
                        .interest,
                    100
                ),
                tokenPrice
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

        // token transfer
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

    // ************************************ Lottery ***************************************

    /**
     * @dev Mapping with key value uint (lottery ticket) leads to the information on ticket
     * amount and time tier for the user to redeem his reward staking.
     */
    mapping(address => bool) lotteryBook;

    /**
     * @dev Getter function to pull information on lottery winner
     * @param _userAddress address of user queried
     * @return if user has a multiplier ready to be reedemed
     */
    function lotteryWinner(address _userAddress) public view returns (bool) {
        return (lotteryBook[_userAddress]);
    }

    /**
     * @dev Address of lottery contract in charge of executing LotteryWinner function
     */
    address Lottery;

    /**
     * @dev Setter function to change the contract address for the lottery connected to
     * staking.
     * @notice This action can only be perform under dev vote.
     * @param _lotteryAddress address of lottery contract picking winners.
     */
    function setLottery(address _lotteryAddress) public {
        Lottery = _lotteryAddress;
    }

    /**
     * @dev Getter function to pull current lottery address
     * @return address of contract
     */
    function getLottery() public view returns (address) {
        return Lottery;
    }

    /**
     * @dev Modifier ensures only the lottery is allowed to pick new winners
     */
    modifier isLotteryContract {
        require(msg.sender == Lottery);
        _;
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

    // ******************************** Fee mechanism ***********************************
    /**
     * @dev
     */
    address WithdrawContract;

    /**
     * @dev
     */
    function setContract(address _treasuryAddress) public {
        WithdrawContract = _treasuryAddress;
    }

    /**
     * @dev Saving running fee total
     */
    uint256 public totalFeeBalance;

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
     * @dev Variable for staking flat fee.
     */
    uint256 fee;

    /**
     * @dev Setter for staking flat fee.
     * @param _newFee new uint fee value.
     * @notice This action can only be perform under dev vote.
     */
    function newFee(uint256 _newFee) public {
        fee = _newFee;
    }

    modifier onlyTreasury {
        require(
            msg.sender == WithdrawContract,
            "This address can't withdraw funds from treasury"
        );
        _;
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
//       "address": "0xeec17f5200db300964489ae126baf9671e30df6a",
//       "transactionHash": "0x685ff3b12fbee153d9ac0397836f60ac75b3df6182ffdb9d27c9a00579c40c74"
//     }
