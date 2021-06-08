

import "./interfaces/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/SafeMath.sol";
import "./interfaces/UniversalERC20.sol";
import "./ExchangeOracle.sol";


// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;




contract Voting {

mapping(address => Loan) loanBook;

mapping(uint256 => mapping(address => bool)) voteBook;

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
        uint64 no; // Amount of votes for no
    }






// **************************** Voting Testing for Binance Smart chain and Ethereum Blockchain  ******************************

enum State { Created, Voting, Ended}
State public state;


modifier inState(State _state) {
        require(state == _state);
        _;
    }

 function startVote()
        internal
        inState(State.Created)
        {
            state = State.Voting;
            
        }
 function doVote(uint256 _signature, bool _vote)
        public
        inState(State.Voting)
        returns (bool voted)
    {
         bool found = false;
         require(
             voteBook[_signature][msg.sender] == false,
             "You have already voted."
         );
         voteBook[_signature][msg.sender] = true;
         if (_vote == true) {
             loanBook[msg.sender].yes++;
         } else {
             loanBook[msg.sender].no++;
         }
         loanBook[msg.sender].totalVote++;
         return true;
     }
     
     
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


// using simple sample functions to compare the two chains

// struct vote{
//      address voterAddress;
//      bool choice;
// }

// struct voter{
//     string voterName;
//     bool voted;
// }

// mapping(uint => vote) private votes;
// mapping(address => voter) public voterRegister;

// uint pirvate countResult = 0;

// uint public finalResult= 0;
// uint public totalVoter = 0;
// uint public totalVote = 0;

// address public ballotOfficialAddress;
// string public ballotOfficialName;
// string public proposal;




// constructor(
    
//     string memory _ballotOfficialName,
//     string memory _proposal) public {
//         ballotOfficialAddress = msg.sender;
//         ballotOfficialName = _ballotOfficialName;
//         proposal = _proposal;
        
//         state = state.Created;
//     }
    
    // function addVoter(address _voterAddress , string memory _voterName) 
    //     public inState(State.Created)
    //     onlyOfficial
    //     {
    //         voter memory v;
    //         v.voterName = _voterName;
    //         v.voted = false ;
    //         voterRegister[_voterAddress] = v;
    //         totalVoter++;
    //         emit voterAdded(_voterAddress);
            
            
    //     }
    
    // modifier inState(State _state)
    // {
    //     require(state == _state);
    //     _;
    // }
    
    // modifier onlyOfficial{
    //      require(msg.sender == ballotOfficialAddress);
    //      _;
    // }
    
    
   
        
        
        
        

 // **************************** Voting From When Voting was done ******************************
    
    
//     mapping(uint256 => mapping(address => bool)) voteBook; // Signature key => mapping( voters => voted)

//     mapping(uint256 => address[]) uintArray;

//     //


//     // mapping(uint => uint) voterCost;


//     // User tries to vote
//     // Contract checks if they have sufficient funds in CBLT tokens - Tiers
//     // Function checks if 7 days have passsed since loan first went into voting
//     // Function checks if loan array has a length <= tier max
//     // Voter casts votes
//     // Vote gets added to counter to yes or no in loan
//     // msg.sender is added to uintArray - Access with the unique signature for each loan
//     // Validate loan checking if enough votes have been casted. 21% of the votes
//     // Check if majority of the votes say yes or no
//     // Change loan status depending on how voting went
//     // Give second wind to the loan depending on if its the first time
//     // Reset voting but keep voters inside
//     // Update 1 ---
//     // -------- Add an address array to keep track of the users we owe interest to
//     // -------- No second-wind option for loans (being discussed)
//     // -------- Payout for voters occurs at the end but payment of interest is prioritized

//     enum State {Created, Voting, Ended}
//     State public state;

//     modifier inState(State _state) {
//         require(state == _state);
//         _;
//     }

//     /**
//      * @dev creating function the right to vote
//      * if a person holds a certain amount of CBLT
//      * they can for tier 1
//      *
//      */
     
//     // function rightToVoteTiers(address loanSignature) internal view {
//     //     // uint256 balanceInCBLT =
//     //     //      SafeMath.add(
//     //     //         token.balanceOf(msg.sender),
//     //     //         userBook[msg.sender].rewardWallet
//     //     //     );

//     //     // PULL FROM ORACLE // ORACLE ENTRY!!!!!
//     //     uint256 USDtoCBLT =
//     //         SafeMath.div(
//     //             1000000000000000000,
//     //             SafeMath.mul(2000000000000, 2843)
//     //         );
//     // }

//     /**
//      * @dev starts the voting process
//      *
//      */
//     function startVote() internal inState(State.Created) {
//         state = State.Voting;
//     }

//     /**
//      * @dev DOES the vote takes in the voter choice
//      *
//      */

//     function doVote(uint256 _signature, bool _vote)
//         public
//         inState(State.Voting)
//         returns (bool voted)
//     {
//         // bool found = false;
//         // require(
//         //     voteBook[_signature][msg.sender] == false,
//         //     "You have already voted."
//         // );
//         // voteBook[_signature][msg.sender] = true;
//         // if (_vote == true) {
//         //     loanBook[msg.sender].yes++;
//         // } else {
//         //     loanBook[msg.sender].no++;
//         // }
//         // loanBook[msg.sender].totalVote++;
//         // return true;
//     }

//     /**
//      * @dev Ends the voting
//      *
//      */

//     function endVote() internal inState(State.Voting) {
//         // the  1619656173 represents 7 days in epoch and must be less then 7 days
//         uint256 weekOfEpoch = 1619656173;

//         // in which it requires at least 50% of the voters to past
//         // will not use multiple ifs for tiers to save on gas
//         if (loanBook[msg.sender].timeCreated <= weekOfEpoch) {
//             require(
//                 SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 100) >= 50
//             );
//             require(
//                 SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 200) >= 50
//             );
//             require(
//                 SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 400) >= 50
//             );
//             require(
//                 SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 800) >= 50
//             );
//             require(
//                 SafeMath.multiply(loanBook[msg.sender].totalVote, 50, 1600) >=
//                     50
//             );

//             state = State.Ended;
//         } else {
//             state = State.Ended;
//         }
//     }
// }

}
