pragma solidity ^0.4.25;


contract Auction {
    
    // state variables that are constant
    address public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    uint public bidIncreament;
    
    // state variables that changes as the auction progresses
    enum State {Started,Running,Ended,Canceled}
    State public auctionState;
    
    address public highestBidder;
    uint public highestBid;
    uint public highestBindingBid;
    mapping(address => uint) Bids;
    
    // (address _owner, uint _bidIncrement, uint _startBlock, uint _endBlock, string _ipfsHash
    
    constructor() public {
        // require(_owner != 0 && _startBlock < _endBlock && _startBlock >= block.number);
         auctionState = State.Running;
        // owner = _owner;
        // startBlock=_startBlock;
        // endBlock=_endBlock;
        // bidIncreament = _bidIncrement;
        // ipfsHash=_ipfsHash;
        
        
        // Just for testing
        owner = msg.sender;
        startBlock = block.number;
        endBlock = startBlock + 3;
        ipfsHash = "";
        bidIncreament =1000000000000000000;
       
    }
    
    modifier notOwner{
        require(msg.sender != owner);
        _;
    }
    
     modifier auctionStarted{
        require(block.number >= startBlock);
        _;
    }
    
     modifier auctionNotEnded{
        require(block.number <= endBlock );
        _;
    }
    
    modifier isOwner {
        require(msg.sender == owner);
        _;
    }
    
    function min(uint a,uint b) internal pure returns(uint){
        if(a <= b){
            return a;
        }
        else{
            return b;
        }
    }
    
    function cancelAuction() public isOwner auctionNotEnded {
        auctionState = State.Canceled;
    }
    
    function placeBid() public payable notOwner auctionStarted auctionNotEnded{
        
        require(auctionState == State.Running);
        require(msg.value != 0);
        
        uint currentBid;
        
        currentBid = Bids[msg.sender] + msg.value;
        
        require(currentBid > highestBindingBid);
        
        highestBid = Bids[highestBidder];
        Bids[msg.sender] = currentBid;
        
        if(currentBid > highestBindingBid && currentBid < highestBid)
        {
            highestBindingBid = min(currentBid+bidIncreament,highestBid);
        }
        else{
            if(msg.sender != highestBidder)
            {
                highestBidder = msg.sender;
                highestBindingBid = min(highestBid+bidIncreament,currentBid);
                
            }
            highestBid = currentBid;
        }
        
        
    }
    
    
    function withDraw() public {
        require(auctionState == State.Canceled || block.number > endBlock);
        address recepient;
        uint value;
        
       if(auctionState == State.Canceled)
       {
           recepient = msg.sender;
           value = Bids[msg.sender];
       }
       else
       {
           if(msg.sender == owner)
           {
               recepient = owner;
               value=highestBindingBid;
           }
           else{
               if(msg.sender == highestBidder){
                   recepient = highestBidder;
                   value= Bids[highestBidder]-highestBindingBid;
               }
               else
               {
                   recepient = msg.sender;
                   value = Bids[msg.sender];
               }
           }
       }
       
       if(value != 0){
           Bids[recepient] -= value;
           
           if(!recepient.send(value))
           {
               Bids[recepient] += value;
           }
       }
    }
}





