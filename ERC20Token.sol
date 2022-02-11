pragma solidity ^0.8.0;


interface ERC20Interface {
   function transfer(address to, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);
    function balanceOf(address tokenOwner) external returns(uint balance);
    function approve(address spender, uint tokens) external returns(bool success);
    function allowance(address tokenOwner, address spender) external returns(uint remaining);
    function totalSupply()  external  returns(uint); 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
} 

  contract ERC20Token  {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupplys;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;  

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _totalSupply 
    ){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupplys = _totalSupply;
        balances[msg.sender] =_totalSupply;  
    }

    function transfer(address to, uint value) external returns(bool){
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender,to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool){
        uint allowance = allowed[from][msg.sender];
        require(balances[msg.sender] >= value && allowance  >= value);
        allowed[from][msg.sender] -= value;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender,to, value);
        return true; 
    }

    function approve(address spender,uint value) public returns(bool){
        require(spender != msg.sender);
        allowed[msg.sender][spender]= value;
        emit Approval(msg.sender,spender,value);
        return true;
    }
    function allowance(address owner, address spender) public view returns(uint){
        return allowed[owner][spender];
    }
    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }
}