// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

<<<<<<< HEAD
import "./interfaces/SafeMath.sol";
import "./interfaces/Ownable.sol";
import "./interfaces/UniversalERC20.sol";
import "./Bank.sol";

contract EscrowManager is Ownable {
    using UniversalERC20 for IERC20;

    /**
     * @dev these are all the states that the job can be in.
     * ESCROW_CREATED_PAYMENT_DEPOSITED is when the job was created and eth deposited into contract
     * JOB_COMPLETED is when the payee confirms that the job has been JOB_COMPLETED
     * PAYMENT_SENT_PAYEE is when the creator confirms job is done and eth is sent to payee
     * DISPUTE is when creator and payee don't agree
     * PAYMENT_SENT_BACK can only be set if the job was in dispute and we think that he needs his money
     * back because the payee didn't do something correctly
     */
    enum State {
        ESCROW_CREATED_PAYMENT_DEPOSITED,
        JOB_COMPLETED,
        PAYMENT_SENT_PAYEE,
        DISPUTE,
        PAYMENT_SENT_CREATOR
    }

    // the details of the job
    struct EscrowInfo {
        address payable escrowCreator;
        address payable payee;
        string escrowDetails;
        uint256 priceInWei;
        uint256 paidWei;
        bool jobCompletion;
        bool confirmJobCompletion;
        EscrowManager.State state;
    }

    // default eth address the contract is going to use
    IERC20 private constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // creates an instance of the bank
    Bank treasury;

    // used to index each job, each job that is created will increment this by 1
    uint256 index;

    // used to hold the amount of fees collected (0.5% for each job)
    uint256 public fees;

    // mapping of the index to the job details
    mapping(uint256 => EscrowInfo) public escrows;

    /**
     * mapping of each transactions for each index/job.
     * mainly used to keep track of where the money is. if both are at 0,
     * then the funds were returned to creator after dispute.
     */
    mapping(uint256 => mapping(address => uint256)) public transactions;

    // emits everytime the job state changes
    event JobState(uint256 _jobIndex, uint256 _state);

    // emits if there is a dispute and has to be mediated
    event JobDispute(uint256 _jobIndex, uint256 _state);

    /**
     * @dev this function will create the job and accept the deposit from the creator.
     * @param _payee is the person that is going to be paid once job is _completed
     * @param _escrowDetails a description of what the job is
     * @param _priceInWei the price that is going to be deposited and paid to the payee
     */
    function createItemAndDepositFunds(
        address payable _payee,
        string memory _escrowDetails,
        uint256 _priceInWei
    ) external payable {
        require(
            msg.sender != _payee,
            "You can't have the same address as the payee."
        );
        require(msg.value != 0, "msg.value can not equal 0");
        require(_priceInWei == msg.value, "Amount deposited must equal price.");

        escrows[index].escrowCreator = payable(msg.sender);
        escrows[index].payee = _payee;
        escrows[index].escrowDetails = _escrowDetails;
        escrows[index].priceInWei = _priceInWei;
        //  NEEDS TO CHANGE // COMMENTED OUT FOR AT MOMENT
        // escrows[index].paidWei = SafeMath.sub(
        //     msg.value,
        //     SafeMath.findFee(msg.value)
        // );

        // fees = SafeMath.add(fees, SafeMath.findFee(msg.value));
        transactions[index][msg.sender] = escrows[index].paidWei;
        transactions[index][escrows[index].payee] = 0;
        escrows[index].state = State.ESCROW_CREATED_PAYMENT_DEPOSITED;

        emit JobState(index, uint256(escrows[index].state));
        index++;
    }

    /**
     * @dev this function will allow the payee to let the creator know they have completed the job.
     * @param _index is the job index
     * @param _completed this will be true if he completed the task and false if he wants to dispute it
     */
    function jobCompletion(uint256 _index, bool _completed) public {
        require(
            escrows[_index].payee == msg.sender,
            "Only the payee is allowed to complete job."
        );
        require(
            escrows[_index].state == State.ESCROW_CREATED_PAYMENT_DEPOSITED,
            "Job is not at this state yet."
        );

        escrows[_index].jobCompletion = _completed;

        if (_completed) {
            escrows[_index].state = State.JOB_COMPLETED;
            emit JobState(_index, uint256(escrows[_index].state));
        } else {
            escrows[_index].state = State.DISPUTE;
            emit JobDispute(_index, uint256(escrows[_index].state));
        }
    }

    /**
     * @dev this function will allow the creator to confirm that the job is complete and then will pay the payee
     * @param _index is the index of the job
     * @param _satisfied this will be true if he is _satisfied and then the funds will be sent to the payee
     * and it will be false if he wants to dispute it.
     */
    function confirmJobCompletion(uint256 _index, bool _satisfied) external {
        require(
            escrows[_index].escrowCreator == msg.sender,
            "Only the job creator can confirm job completion."
        );
        require(
            escrows[_index].state == State.JOB_COMPLETED,
            "Job is not at this state yet."
        );

        escrows[_index].confirmJobCompletion = _satisfied;

        if (_satisfied) {
            sendFundsToPayee(_index);
            emit JobState(_index, uint256(escrows[_index].state));
        } else {
            escrows[_index].state = State.DISPUTE;
            emit JobDispute(_index, uint256(escrows[_index].state));
        }
    }

    /**
     * @dev this function will resolve any dispute that occurs. The owner of the contract will be
     * able to talk to both parties and come up with a decision on who is correct.
     * @param _index this is the index of the job
     * @param _setState is the state that the mediator wants to put the job to
     */
    function resolveDispute(uint256 _index, State _setState)
        external
        onlyOwner
    {
        require(
            escrows[_index].state == State.DISPUTE,
            "This job is not in dispute."
        );

        if (_setState == State.PAYMENT_SENT_PAYEE) {
            sendFundsToPayee(_index);
            emit JobState(_index, uint256(escrows[_index].state));
        } else if (_setState == State.PAYMENT_SENT_CREATOR) {
            sendFundsToCreator(_index);
            emit JobState(_index, uint256(escrows[_index].state));
        } else {
            escrows[_index].state = _setState;
            emit JobState(_index, uint256(escrows[_index].state));
        }
    }

    /**
     * @dev this function will set the treasury
     */
    function setTreasury(address payable _treasury) external onlyOwner {
        treasury = Bank(_treasury);
    }

    /**
     * @dev this function will send funds back to the creator, can only be called
     * inside of another function
     * @param _index is the index of the job
     */
    function sendFundsToCreator(uint256 _index) private {
        require(
            ETH_ADDRESS.universalTransfer(
                escrows[_index].escrowCreator,
                escrows[_index].paidWei
            ),
            "Transfer didn't complete"
        );
        transactions[_index][escrows[_index].escrowCreator] = 0;
        escrows[_index].state = State.PAYMENT_SENT_CREATOR;
    }

    /**
     * @dev this function will send the funds to the payee
     * @param _index is the index of the jobs
     */
    function sendFundsToPayee(uint256 _index) private {
        require(
            ETH_ADDRESS.universalTransfer(
                escrows[_index].payee,
                escrows[_index].paidWei
            ),
            "Transfer didn't complete."
        );
        transactions[_index][escrows[_index].escrowCreator] = 0;
        transactions[_index][escrows[_index].payee] = escrows[_index].paidWei;
        escrows[_index].state = State.PAYMENT_SENT_PAYEE;
    }

    /**
     * @dev this function will deposit the fees into the treasury
     */

    // GIVING ME AN ERROR -- NEEDS TO CHANGE
    function depositFees() external onlyOwner {
        // treasury.depositTokens(address(ETH_ADDRESS), fees);
=======
import './Escrow.sol';

contract EscrowManager {

    event CreatedEscrow(address escrow, address creator, address payee, uint createAt, uint amount);

    mapping(address => Escrow[]) escrows;
    address mediator;

    constructor() {
        mediator = msg.sender;
    }

    function getEscrows(address _user)
    external
    view
    returns (Escrow[] memory)
    {
        return escrows[_user];
    }

    function newEscrowContract(address payable _payee, string memory _escrowDetails, uint _priceInWei)
    external
    payable
    returns (Escrow escrow)
    {
        escrow = new Escrow(payable(msg.sender), _payee, mediator, _escrowDetails, _priceInWei);

        escrows[msg.sender].push(escrow);
        escrows[_payee].push(escrow);

        payable(address(escrow)).transfer(msg.value);

        CreatedEscrow(address(escrow), msg.sender, _payee, block.timestamp, _priceInWei);
    }

    receive() external payable{
        revert();
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    }
}
