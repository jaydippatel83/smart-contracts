pragma solidity ^0.8.0;

contract EventContract{

    struct Event{
        address admin;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemaining; 
    }
    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(
        string calldata name,
        uint date,
        uint price,
        uint ticketCount,
        uint ticketRemaining
    )external{
        require(date > block.timestamp,"Event can be organized in the future");
        require(ticketCount > 0 , "can only create event with at least");
        events[nextId] = Event(
            msg.sender,
            name,
            date,
            price,
            ticketCount,
            ticketRemaining
        );
        nextId++;
    }

    function buyTicket(uint id, uint quantity)payable external eventExist(id) eventActive(id){
        Event storage  _event = events[id]; 
        require(msg.value == (_event.price * quantity),"Not enough ether sent");
        require(_event.ticketRemaining >= quantity,"Not enough ticket left");
        _event.ticketRemaining -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint eventId, uint quantity, address to)external eventExist(eventId) eventActive(eventId){
        require(tickets[msg.sender][eventId] >= quantity,"Not enough tickets");
        tickets[msg.sender][eventId] -= quantity;
        tickets[to][eventId] += quantity;
    }
    modifier eventExist(uint id){
        require(events[id].date != 0 ,"THis event does not exist");
        _;
    }
    modifier eventActive(uint id){
         require(block.timestamp < events[id].date,"This event is not active anymore");
        _;
    }
}