pragma solidity ^0.8.0;

contract StateMachine {
    enum State {
        PENDING,
        ACTIVE,
        CLOSE
    }
    State public state = State.PENDING;
    uint256 public amount;
    uint256 public interest;
    uint256 public end;
    address payable public borrower;
    address payable public lender;

    constructor(
        uint256 _amount,
        uint256 _interest,
        uint256 _duration,
        address payable _borrower,
        address payable _lender
    ) {
        amount = _amount;
        interest = _interest;
        end = block.timestamp + _duration;
        borrower = _borrower;
        lender = _lender;
    }

    function find() external payable {
        require(msg.sender == lender, "Only lender can lend");
        require(address(this).balance == amount, "Cannot lend more");
        _transitionTo(State.ACTIVE);
        borrower.transfer(amount);
    }

    function reimburse() external payable {
        require(msg.sender == borrower, "Only borrower can reimburse");
        require(
            msg.value == amount + interest,
            "borrower need to reimburse exactly amount + interest"
        );
        _transitionTo(State.CLOSE);
        lender.transfer(amount + interest);
    }

    function _transitionTo(State to) internal {
        require(to != State.PENDING, "cannot go back to PENDING state");
        require(to != state, "cannot transition to current state");
        if (to == State.ACTIVE) {
            require(
                state == State.PENDING,
                "can only transition to active from pending state"
            );
            state = State.ACTIVE;
        }
        if (to == State.CLOSE) {
            require(
                state == State.ACTIVE,
                "Can only transition to close from Active"
            );
            require(block.timestamp >= end, "Loan has not matured yet!");
            state = State.CLOSE;
        }
    }
}
