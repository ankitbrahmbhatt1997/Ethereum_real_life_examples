pragma solidity ^0.4.25;


contract Lottery{
    address public manager;
    address[] public players;
    
    constructor() public{    //Run only once , at the time of contract deployment
        manager=msg.sender;
    }
    
    function enter() public payable{    // Entering a lottery by sending some ether
        require(msg.value>.01 ether);
        players.push(msg.sender);
    }
    
    function get_balance() public  prevent view returns(uint){  //getting the balance of the contract
        
        return address(this).balance;
    }
    
    function random() private view returns(uint){
      return uint(keccak256(abi.encodePacked(block.difficulty,now,players)));
    }
    
    function pickWinner() public prevent  {
        
        uint index;
        index = random()%players.length;
        address winner;
        winner = players[index];
        winner.transfer(address(this).balance);
        
        players = new address[](0);
    }
    
    modifier prevent() {
        require(msg.sender == manager);
        _;
    }
}