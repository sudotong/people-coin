pragma solidity ^0.4.18;


contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract Rewards is Ownable {
    mapping (address => bool) private isAuthorized;
    mapping (address => uint) public ethBalance;
    mapping (address => mapping (bytes32 => uint)) public peepBalance;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function getEthBalance(address user) external view returns (uint) { return ethBalance[user]; }

    function getPeepBalance(address user, bytes32 eventId) external view returns (uint) { return peepBalance[user][eventId]; }

    function subEth(address user, uint amount) external onlyAuth { ethBalance[user] -= amount; }

    function subPeep(address user, uint amount, bytes32 eventId) external onlyAuth { peepBalance[user][eventId] -= amount; }

    function addEth(address user, uint amount) external onlyAuth { ethBalance[user] += amount; }

    function addPeep(address user, uint amount, bytes32 eventId) external onlyAuth { peepBalance[user][eventId] += amount; }

}

contract priced {
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}

contract PPC is Ownable, priced {

    address peepWallet;
    Events events;
    Rewards rewards;

    bool  contractPaused = false;
    uint  peepBalance = 0;
    uint public playerFunds = 0;
    uint initPrice = 0.001 ether;

    mapping (address => bool) abandoned;
    mapping (address => bool) private isAuthorized;

    modifier notPaused() {
        require (!contractPaused);
        _;
    }

    modifier onlyStaker (bytes32 eventId) {
        require (events.isStaker(eventId, msg.sender));
        _;
    }

    modifier onlyPaused() {
        require (contractPaused);
        _;
    }

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function () payable public {
        if (msg.sender != address(events)) {
            playerFunds += msg.value;
        }
    }

    // Constructor
    function PPC () payable public {
        peepWallet = 0x10f5125ECEdd1a0c13de969811A8c8Aa2139eCeb; //TODO: Update with actual token address
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setEventsContract (address thisAddr) external onlyOwner { events = Events(thisAddr); }

    function setRewardsContract   (address thisAddr) external onlyOwner { rewards = Rewards(thisAddr); }

    function setPPCWallet (address newAddress) public onlyOwner { peepWallet = newAddress; }

    function abandonContract() external onlyPaused {
        require(!abandoned[msg.sender]);
        abandoned[msg.sender] = true;
        uint ethBalance =  rewards.getEthBalance(msg.sender);
        playerFunds -= ethBalance;
        if (ethBalance > 0) {
            msg.sender.transfer(ethBalance);
        }
    }

    function changeInitPrice(uint _price) external onlyOwner { initPrice = _price; }

    function initialize(bytes32 id, bytes32 name, uint startTime) notPaused external payable costs(initPrice) returns (uint bought){

        events.makeStandardEvent(id, name, startTime);
        events.addWager(id, initPrice);
        peepWallet.transfer(initPrice);

        // uint initialWager = msg.value - initPrice;
        uint bought = PPC(this).buy(id);

        return bought;
    }

    function buy(bytes32 eventId) notPaused external payable returns (uint bought){
        uint tradePrice = events.getTradePrice(eventId);
        uint amount = msg.value / tradePrice;                     // calculates the amount
        require(msg.value == amount * tradePrice);  // make sure we dont get a division error


        events.addWager(eventId, amount);
        // adds the amount to buyer's balance
        rewards.addPeep(msg.sender, amount, eventId);
        addToPlayerFunds(msg.value);

        // ends function and returns amount bought
        return amount;
    }

    function sell(bytes32 eventId, uint amount) notPaused onlyStaker(eventId) external returns (uint revenue){
        require(rewards.getPeepBalance(msg.sender, eventId) < amount );        // checks if the sender has enough to sell

        uint tradePrice = events.getTradePrice(eventId);
        uint ethValue = tradePrice * amount;
        require(ethValue > playerFunds);

        // remove the amount from buyer's balance
        events.removeWager(eventId, amount);
        rewards.subPeep(msg.sender, amount, eventId);

        subFromPlayerFunds(ethValue);
        if (!msg.sender.send(ethValue)) {                   // sends ether to the seller: it's important, msg.sender.transfer(eth)
            revert();                                         // to do this last to prevent recursion attacks
        } else {
            return ethValue;                                 // ends function and returns
        }
    }

    function pauseContract() public onlyOwner { contractPaused = true; }

    function addToPlayerFunds (uint amount) public onlyAuth { playerFunds += amount; }

    function subFromPlayerFunds (uint amount) public onlyAuth { playerFunds -= amount; }

    function getContractPaused() public constant returns (bool) { return contractPaused; }

}

contract Events is Ownable {
    mapping (address => bool) private isAuthorized;
    uint public eventsCount;
    bytes32[] public activeEvents;

    Rewards rewards;

    struct StandardWagerEvent {
        bytes32 name;
        uint startTime; // Unix timestamp
        uint numWagers;
        uint totalAmountBet;
        uint activeEventIndex;
        bool cancelled;
        address[] Stakers;
    }

    mapping (bytes32 => StandardWagerEvent) standardEvents;

    // Empty mappings to instantiate events
    address[] emptyAddrArray;
    bytes32[] emptyBytes32Array;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setRewardsContract   (address thisAddr) external onlyOwner { rewards = Rewards(thisAddr); }

    function Events () public {
        bytes32 empty;
        activeEvents.push(empty);
    }

    /** @dev Creates a new Standard event struct for users to bet on and adds it to the standardEvents mapping.
      * @param name The name of the event to be diplayed.
      * @param startTime The date and time the event begins in the YYYYMMDD9999 format.
      */
    function makeStandardEvent(bytes32 id, bytes32 name, uint startTime) external {
        StandardWagerEvent memory thisEvent;
        thisEvent = StandardWagerEvent( name, startTime, 0, 0, activeEvents.length, false, emptyAddrArray);
        standardEvents[id] = thisEvent;
        eventsCount++;
        activeEvents.push(id);
    }

    function updateStandardEvent(bytes32 eventId, uint newStartTime) external onlyAuth { standardEvents[eventId].startTime = newStartTime; }

    function cancelStandardEvent (bytes32 eventId) external onlyAuth {
        standardEvents[eventId].cancelled = true;
        uint indexToDelete = standardEvents[eventId].activeEventIndex;
        uint lastItem = activeEvents.length - 1;
        activeEvents[indexToDelete] = activeEvents[lastItem]; // Write over item to delete with last item
        standardEvents[activeEvents[lastItem]].activeEventIndex = indexToDelete; //Point what was the last item to its new spot in array
        activeEvents.length -- ; // Delete what is now duplicate entry in last spot
    }

    function removeEventFromActive (bytes32 eventId) public onlyAuth {
        uint indexToDelete = standardEvents[eventId].activeEventIndex;
        uint lastItem = activeEvents.length - 1;
        activeEvents[indexToDelete] = activeEvents[lastItem]; // Write over item to delete with last item
        standardEvents[activeEvents[lastItem]].activeEventIndex = indexToDelete; //Point what was the last item to its new spot in array
        activeEvents.length -- ; // Delete what is now duplicate entry in last spot
    }

    function removeWager (bytes32 eventId, uint value) external {
        if (isStaker(eventId, msg.sender)){
            standardEvents[eventId].numWagers --;
            standardEvents[eventId].totalAmountBet -= value;
        }
    }

    function addWager(bytes32 eventId, uint value) external {
        standardEvents[eventId].numWagers ++;
        standardEvents[eventId].totalAmountBet += value;
    }

    function getTradePrice(bytes32 eventId) external view returns (uint) { return standardEvents[eventId].totalAmountBet - rewards.getPeepBalance(msg.sender, eventId); }

    function getActiveEventId (uint i) external view returns (bytes32) { return activeEvents[i]; }

    function getActiveEventsLength () external view returns (uint) { return activeEvents.length; }

    function getStandardEventCount () external view returns (uint) { return eventsCount; }

    function getTotalAmountBet (bytes32 eventId) public view returns (uint) { return standardEvents[eventId].totalAmountBet; }

    function getCancelled(bytes32 id) external view returns (bool) { return standardEvents[id].cancelled; }

    function getStart (bytes32 id) public view returns (uint) { return standardEvents[id].startTime; }

    function isStaker (bytes32 id, address user ) public view returns (bool) { return rewards.getPeepBalance(user, id) > 0; }

}
