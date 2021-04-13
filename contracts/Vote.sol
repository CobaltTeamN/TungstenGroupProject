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


}


