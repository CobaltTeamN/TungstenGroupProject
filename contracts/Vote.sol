// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Votes{

    struct vote{
        address voterAddress;
        bool choice;
    }

    struct voters{
        string voteName;
        bool voted;
    }

    mapping(uint => vote) private votes;
    mapping(address => voters) public voterRegister;

    uint private countResult = 0;


    uint public finalResult= 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;

    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;


    enum State{ Created, Voting , Ended}
    State public state;


    constructor(string memory _ballotOfficialName,
        string memory _proposal) public{

            ballotOfficialAddress = msg.sender;
            ballotOfficialName = _ballotOfficialName;
            proposal = _proposal;

            state = State.Created;
        }

        /**
     * @dev adds a voter by takin in two parameter the voters address and a voter name.
     *  
     */
        function addVoter(address _voterAddress, string memory _voterName)
        public inState(State.Created)onlyOfficial{

            voter memory v;
            v.voterName = _voterName;
            v.voted = false;
            voterRegister[_voterAddress] = v;
            totalVoter++;
            emit voterAdded(_voterAddress);
        }
    modifier inState(State _state){
        require(state == _state);
        _;
    }

    modifier onlyOfficial(){
        require(msg.sender == ballotOfficialAddress);
        _;
    }


    
        /**
     * @dev starts the voting process
     *  
     */
    function startVote() public inState(State.Created) onlyOfficial{
        state = State.Voting;
        emit voteStarted();
    }

      /**
     * @dev DOES the vote takes in the voter choice
     *  
     */
    function doVote(bool _choice) public inState(State.Voting)
    returns (bool voted)
    {
        bool found = false;
        if(bytes(voterRegister[msg.sender].voterName).length != 0
        && !voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;

            if(_choice){
                countResult++;
            }
            votes[totalVote] = v;
            totalVote++;

            found = true;
        }
        emit voteDone(msg.sender);
        return found;

     
    }

     /**
     * @dev Ends the voting 
     *  
     */
        function endVote()public inState(State.Voting)
        onlyOfficial{

            
            state = State.Ended;
            finalResult = countResult;

            emit voteEnded(finalResult);
        }
       
        // if voting is past 7 days then loan ends. Must be take take 21 votes 

         uint number = 100/5

         if( number > )
         {

         }

}


