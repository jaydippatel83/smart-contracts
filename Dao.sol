pragma solidity ^0.8.0;

contract DAO {

struct Proposal{
    uint id;
    string name;
    uint amount;
    address payable recipient;
    uint votes;
    uint end;
    bool executed;
}

  mapping(address => bool) public investors;
  mapping(address => uint) public shares;
  mapping(uint => Proposal) public proposals;
  mapping(address => mapping(uint => bool)) public votes;

  uint public totalShares;
  uint public availableFunds;
  uint public contributionEnd;
  uint public nextproposalId;
  uint public voteTime;
  uint public quorum;
  address public admin;

  constructor(uint contributionTime)  {
    contributionEnd = block.timestamp + contributionTime;
  }

  function contribute() payable external {
    require(block.timestamp < contributionEnd, 'cannot contribute after contributionEnd');
    investors[msg.sender] = true;
    shares[msg.sender] += msg.value;
    totalShares += msg.value;
    availableFunds += msg.value;
  }

  function redeemShare(uint amount) external {
    require(shares[msg.sender] >= amount, 'not enough shares');
    require(availableFunds >= amount, 'not enough available funds');
    shares[msg.sender] -= amount;
    availableFunds -= amount; 
    payable(msg.sender).transfer(amount);
  }
    
  function transferShare(uint amount, address to) external {
    require(shares[msg.sender] >= amount, 'not enough shares');
    shares[msg.sender] -= amount;
    shares[to] += amount;
    investors[to] = true;
  }
  function createProposal(string memory name,uint amount, address payable recipient) external onlyInvestors(){
      require(availableFunds >= amount,"Amount to big");
      proposals[nextproposalId] = Proposal(
          nextproposalId,
          name,
          amount,
          recipient,
          0,
          block.timestamp + voteTime,
          false
      );
      availableFunds -= amount;
      nextproposalId ++; 
  }

  function vote(uint proposalId) external onlyInvestors(){
      Proposal storage proposal = proposals[proposalId];
      require(votes[msg.sender][proposalId]== false,'inverstor can only');
      require(block.timestamp < proposal.end,"can only vote uintil proposal end");
      votes[msg.sender][proposalId] = true;
      proposal.votes += shares[msg.sender];
  }

  function executeProposal(uint proposalId) external onlyAdmin(){
       Proposal storage proposal = proposals[proposalId];
       require(block.timestamp >= proposal.end,"Cannot execue proposal befor end Date");
       require(proposal.executed == false ,"cannot execute proposal already executed");
       require((proposal.votes / totalShares) * 100 >= quorum,"cannot execute a proposal with votes below quorum");
       _transferEther(proposal.amount,proposal.recipient);
  }

  function withdrawEther(uint amount,address payable to)external onlyAdmin(){
      _transferEther( amount, to);
  }

  fallback() external payable{
      availableFunds += msg.value;
  }

  function _transferEther(uint amount, address payable to) internal{
      require(amount <= availableFunds,"Not enough availabale funds");
      availableFunds -= amount;
      to.transfer(amount);
  }

  modifier onlyInvestors(){
      require(investors[msg.sender] == true,"Only Investors");
      _;
  }

  modifier onlyAdmin(){
      require(msg.sender == admin,"Only Admin");
      _;
  }
}
