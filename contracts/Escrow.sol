// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './interfaces/SafeMath.sol';
import './interfaces/Ownable.sol';
import './interfaces/UniversalERC20.sol';

contract Escrow is Ownable {
    using UniversalERC20 for IERC20;

    modifier onlyEscrowCreator {
        escrowCreator == msg.sender;
        _;
    }

    modifier onlyPayee {
        payee == msg.sender;
        _;
    }

    modifier onlyMediator {
        mediator == msg.sender;
        _;
    }

    /**
     * @dev these are all the states that the job can be in.
     * ESCROW_CREATED_PAYMENT_DEPOSITED is when the job was created and eth deposited into contract
     * JOB_COMPLETED is when the payee confirms that the job has been JOB_COMPLETED
     * PAYMENT_SENT_PAYEE is when the creator confirms job is done and eth is sent to payee
     * DISPUTE is when creator and payee don't agree
     * PAYMENT_SENT_BACK can only be set if the job was in dispute and we think that he needs his money
     * back because the payee didn't do something correctly
    */
    enum State {ESCROW_CREATED_PAYMENT_DEPOSITED, JOB_COMPLETED, PAYMENT_SENT_PAYEE, DISPUTE, PAYMENT_SENT_CREATOR}

    address payable escrowCreator;
    address payable payee;
    address mediator;
    string escrowDetails;
    uint priceInWei;
    uint paidWei;
    State public state;

    // default eth address the contract is going to use
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // emits everytime the job state changes
    event JobState(State _state);

    // emits whenever a payment has been sent to someone
    event PaymentSent(address to, uint amount);


    /**
     * @dev this function will create the job and accept the deposit from the creator.
     * @param _payee is the person that is going to be paid once job is _completed
     * @param _escrowDetails a description of what the job is
     * @param _priceInWei the price that is going to be deposited and paid to the payee
    */
    constructor(
        address payable _creator,
        address payable _payee,
        address _mediator,
        string memory _escrowDetails,
        uint _priceInWei) payable
    {
        require(msg.sender != _payee, "You can't have the same address as the payee.");
        require(msg.value != 0, "msg.value can not equal 0");
        require(_priceInWei == msg.value, "Amount deposited must equal price.");

        escrowCreator = _creator;
        payee = _payee;
        mediator = _mediator;
        escrowDetails = _escrowDetails;
        priceInWei = _priceInWei;
        paidWei = msg.value;
        state = State.ESCROW_CREATED_PAYMENT_DEPOSITED;

        emit JobState(state);
    }


    /**
     * @dev this function will allow the payee to let the creator know they have completed the job.
     * @param _completed this will be true if he completed the task and false if he wants to dispute it
    */
    function completeJob(bool _completed)
    external
    onlyPayee
    {
        require(state == State.ESCROW_CREATED_PAYMENT_DEPOSITED, "Job is not at this state yet.");

        if (_completed) {
            state = State.JOB_COMPLETED;
            emit JobState(state);
        } else {
            state = State.DISPUTE;
            emit JobState(state);
        }

    }

    /**
     * @dev this function will allow the creator to confirm that the job is complete and then will pay the payee
     * @param _satisfied this will be true if he is _satisfied and then the funds will be sent to the payee
     * and it will be false if he wants to dispute it.
    */
    function confirmJobCompletion(bool _satisfied)
    external
    onlyEscrowCreator
    {
        require(state == State.JOB_COMPLETED, "Job is not at this state yet.");

        if(_satisfied) {
            sendFundsToPayee();
            state = State.PAYMENT_SENT_PAYEE;
            emit JobState(state);
        } else {
            state = State.DISPUTE;
            emit JobState(state);
        }

    }

    /**
     * @dev this function will resolve any dispute that occurs. The owner of the contract will be
     * able to talk to both parties and come up with a decision on who is correct.
     * @param _setState is the state that the mediator wants to put the job to
    */
    function resolveDispute(State _setState) external onlyMediator {
        require(state == State.DISPUTE, "This job is not in dispute.");

        if(_setState == State.PAYMENT_SENT_PAYEE) {
            sendFundsToPayee();
            emit JobState(state);

        } else if (_setState == State.PAYMENT_SENT_CREATOR) {
            sendFundsToCreator();
            emit JobState(state);
        } else {
            state = _setState;
            emit JobState(state);
        }
    }

    /**
     * @dev this function will send funds back to the creator, can only be called
     * inside of another function
    */
    function sendFundsToCreator() private {
        require(ETH_ADDRESS.universalTransfer(escrowCreator, paidWei), "Transfer didn't complete");
        state = State.PAYMENT_SENT_CREATOR;
        emit PaymentSent(escrowCreator, paidWei);
    }

    /**
     * @dev this function will send the funds to the payee
    */
    function sendFundsToPayee() private {
        require(ETH_ADDRESS.universalTransfer(payee, paidWei), "Transfer didn't complete.");
        state = State.PAYMENT_SENT_PAYEE;
        emit PaymentSent(payee, paidWei);
    }

}
