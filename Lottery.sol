pragma solidity ^0.8.0;

contract Lottery{
    enum State{
        IDEL,
        BETTING
    }
    State public currentState = State.IDEL;
    address payable[] public players;
    uint public betCount;
    uint public betSize;
    uint public houseFee;
    address public admin;

    constructor(uint fee){
        require(fee > 1 && fee < 99 ,"fee should be 1 to 99");
        houseFee = fee;
        admin = msg.sender;
    } 
    function createBet(uint count, uint size) 
    external
    payable
    inState(State.IDEL)
    onlyAdmin()
    {
        betCount = count;
        betSize = size;
        currentState = State.BETTING;
    }

    function bet() external payable inState(State.BETTING){
        require(msg.value == betSize , "Can only bet exactly the "); 
        players.push(payable(msg.sender));
        if(players.length == betCount){
            uint winner =  _randomModulo(betCount);
            players[winner].transfer((betSize * betCount) * (100 - houseFee) / 100);
            currentState = State.IDEL;
            delete players; 
        }
    }

    function cancel() external inState(State.BETTING) onlyAdmin(){
        for(uint i =0; i < players.length ; i ++){
            players[i].transfer(betSize);
        }
        delete players;
        currentState = State.IDEL;
    }

    function _randomModulo(uint modulo) view internal returns(uint) {
       return uint( keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % modulo;
    }


    modifier inState(State state){
        require( currentState == state,"Current state does not allow");
        _;
    }
    modifier onlyAdmin(){
        require(msg.sender == admin ," Only admin");
        _;
    }
}