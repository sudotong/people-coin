pragma solidity ^0.4.18;


import "./PeepCoin.sol";

contract WagersController is Ownable {
    mapping (address => bool) private isAuthorized;
    PPC ppcoin;
    Wagers wagers;
    Events events;
    Admin admin;
    Rewards rewards;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    modifier requireMinWager() {
        require (msg.value >= admin.getMinWagerAmount());
        _;
    }

    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getBettor(wagerId)); // TODO
        _;
    }

    modifier checkBalance (uint wagerValue) {
        require (rewards.getEthBalance(msg.sender) + msg.value >= wagerValue);
        _;
    }

    modifier notPaused() {
        require (!ppcoin.getContractPaused());
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setPPCContract (address thisAddr) external onlyOwner { ppcoin = PPC(thisAddr); }

    function setWagersContract (address thisAddr) external onlyOwner { wagers = Wagers(thisAddr); }

    function setRewardsContract (address thisAddr) external onlyOwner { rewards = Rewards(thisAddr); }

    function setAdminContract (address thisAddr) external onlyOwner { admin = Admin(thisAddr); }

    function setEventsContract (address thisAddr) external onlyOwner { events = Events(thisAddr); }

    /** @dev Creates a new Standard wager for a user to take and adds it to the standardWagers mapping.
      * @param wagerId sha3 hash of the msg.sender concat timestamp.
      * @param eventId int id for the standard event the wager is based on.
      */
    function makeWager(bytes32 wagerId, uint value, bytes32 eventId) public requireMinWager checkBalance(value) notPaused payable {

        wagers.makeWager( wagerId, value, eventId, msg.sender);
        transferEthToPPC(msg.value);
        ppcoin.addToPlayerFunds(msg.value);
        //events.addWager(eventId, wagerId);
        rewards.addEth(msg.sender, msg.value);
    }

    /** @dev Takes a listed wager for a user -- adds address to StandardWager struct.
     * @param id sha3 hash of the msg.sender concat timestamp.
     */
    function takeWager (bytes32 id) public notPaused payable {
        uint expectedValue = wagers.getOrigValue(id);
        require (rewards.getEthBalance(msg.sender) + msg.value >= expectedValue);
        transferEthToPPC(msg.value);
        ppcoin.addToPlayerFunds(msg.value);
        rewards.addEth(msg.sender, msg.value);
        // TODO better winnign value
        events.addWager(wagers.getEventId(id), 90);

    }

    function transferEthToPPC (uint amount) internal { ppcoin.transfer(amount); }

}

contract Wagers is Ownable {

    Events events;
    Rewards rewards;
    PPC ppcoin;

    struct Wager {
        bytes32 eventId;
        uint origValue;
    }

    mapping (bytes32 => Wager) wagersMap;
    mapping (address => mapping (bytes32 => bool)) recdRefund;
    mapping (address => bool) private isAuthorized;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) external onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) external onlyOwner { isAuthorized[unauthorized] = false; }

    function makeWager (bytes32 wagerId, uint value, bytes32 eventId, address bettor) external onlyAuth {
        Wager memory thisWager = Wager (eventId,value);
        wagersMap[wagerId] = thisWager;
        // TODO add bettor somewhere
    }

    function setRefund (address bettor, bytes32 wagerId) external onlyAuth { recdRefund[bettor][wagerId] = true; }

    function getEventId(bytes32 wagerId) external view returns (bytes32) { return wagersMap[wagerId].eventId; }

    function getRefund (address bettor, bytes32 wagerId) external view returns (bool) { return recdRefund[bettor][wagerId]; }

    function getOrigValue (bytes32 id) external view returns (uint) { return wagersMap[id].origValue; }
}


contract Rewards is Ownable {
    mapping (address => bool) private isAuthorized;
    Admin admin;
    Wagers wagers;
    mapping (address => uint) public ethBalance;
    mapping (address => uint) public peepBalance;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setAdminContract (address thisAddr) external onlyOwner { admin = Admin(thisAddr); }

    function setWagersContract (address thisAddr) external onlyOwner { wagers = Wagers(thisAddr); }

    function getEthBalance(address user) external view returns (uint) { return ethBalance[user]; }

    function getPeepBalance(address user) external view returns (uint) { return peepBalance[user]; }

    function subEth(address user, uint amount) external onlyAuth { ethBalance[user] -= amount; }

    function subPeep(address user, uint amount) external onlyAuth { peepBalance[user] -= amount; }

    function addEth(address user, uint amount) external onlyAuth { ethBalance[user] += amount; }

    function addPeep(address user, uint amount) external onlyAuth { peepBalance[user] += amount; }

}






contract PPC is Ownable {

    address peepWallet;
    Events events;
    Admin admin;
    Wagers wagers;
    Rewards rewards;
    PeepCoin peepCoins;

    bool  contractPaused = false;
    uint  peepBalance = 0;
    uint public playerFunds = 0;

    mapping (bytes32 => bool) validIds;
    mapping (address => bool) abandoned;
    mapping (address => bool) private isAuthorized;

    modifier notPaused() {
        require (!contractPaused);
        _;
    }

    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getBettor(wagerId)); // TODO
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
        if (msg.sender != address(wagers)) {
            peepBalance += msg.value;
        }
    }

    // Constructor
    function PPC () payable public {
        setPPCWallet(msg.sender);
        setPeepCoinContract(0x10f5125ECEdd1a0c13de969811A8c8Aa2139eCeb); //TODO: Update with actual token address
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setEventsContract (address thisAddr) external onlyOwner { events = Events(thisAddr); }

    function setRewardsContract   (address thisAddr) external onlyOwner { rewards = Rewards(thisAddr); }

    function setAdminContract (address thisAddr) external onlyOwner { admin = Admin(thisAddr); }

    function setWagersContract (address thisAddr) external onlyOwner { wagers = Wagers(thisAddr); }

    function setPeepCoinContract (address thisAddr) external onlyOwner { peepCoins = PeepCoin(thisAddr); }

    function setPPCWallet (address newAddress) public onlyOwner { peepWallet = newAddress; }

    function abandonContract() external onlyPaused {
        require(!abandoned[msg.sender]);
        abandoned[msg.sender] = true;
        uint ethBalance =  rewards.getEthBalance(msg.sender);
        uint peepBalance = rewards.getPeepBalance(msg.sender);
        playerFunds -= ethBalance;
        if (ethBalance > 0) {
            msg.sender.transfer(ethBalance);
        }
        if (peepBalance > 0) {
            peepCoins.transfer(msg.sender, peepBalance);
        }
    }


    function withdraw(uint eth, uint peep) notPaused external {
        require (rewards.getEthBalance(msg.sender) >= eth);
        rewards.subEth(msg.sender, eth);
        playerFunds -= eth;
        msg.sender.transfer(eth);
        require (rewards.getPeepBalance(msg.sender) >= peep);
        rewards.subPeep(msg.sender, peep);
        peepCoins.transfer (msg.sender, peep);

    }


    /** @dev Settles the wager if both the maker and taker have voted, pays out if they agree
      * @param wagerId bytes32 id for the wager.
      */
//    function settle(bytes32 wagerId) internal {
//        address maker = wagers.getMaker(wagerId);
//        address taker = wagers.getMaker(wagerId);
//        uint origValue = wagers.getOrigValue(wagerId);
//        rewards.addEth(maker, origValue);
//        rewards.subEth(taker, origValue);
//        payout(wagerId, maker); // TODO wrong payout atm
//    }

    /** @dev Pays out the wager if both the maker and taker have agreed
       * @param wagerId bytes32 id for the wager.
       */
    function payout(bytes32 wagerId, address user) internal {
        uint origVal =  wagers.getOrigValue(wagerId);
        bool tie = false;
        if (tie) { //Tie
            msg.sender.transfer(origVal);

        } else {
            uint payoutValue = 90; // TODO get amount
            rewards.subEth(user, payoutValue);

            // TODO check who we are transferring it tot
            transferEthFromPPC(user, payoutValue);
        }
    }



    // Players should call this when an event has been cancelled. Cancelling not supported atm
//    function playerRefund (bytes32 wagerId) external onlyBettor(wagerId) {
//        require (events.getCancelled(wagers.getEventId(wagerId)));
//        require (!wagers.getRefund(msg.sender, wagerId));
//        wagers.setRefund(msg.sender, wagerId);
//        rewards.addEth(msg.sender, ethStake);
//    }

    function pauseContract() public onlyOwner { contractPaused = true; }

    function addPPCBalance (uint amount) public onlyAuth { peepBalance += amount; }

    function addToPlayerFunds (uint amount) public onlyAuth { playerFunds += amount; }

    function subFromPlayerFunds (uint amount) public onlyAuth { playerFunds -= amount; }

    function getContractPaused() public constant returns (bool) { return contractPaused; }

    function transferTokensToPPC (address player, uint peepStake) internal { peepCoins.transferFrom(player, this, peepStake); }

    function transferTokensFromPPC (address player, uint peepStake) internal { peepCoins.transfer(player, peepStake); }

    function transferEthFromPPC (address recipient, uint amount) internal { recipient.transfer(amount); }

}


contract Events is Ownable {
    mapping (address => bool) private isAuthorized;
    uint public eventsCount;
    bytes32[] public activeEvents;

    Wagers wagers;
    Admin admin;


    struct StandardWagerEvent {
        bytes32 name;
        uint startTime; // Unix timestamp
        uint numWagers;
        uint totalAmountBet;
        uint activeEventIndex;
        bytes32[] wagers;
        bool cancelled;
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

    function setWagersContract (address thisAddr) external onlyOwner { wagers = Wagers(thisAddr); }

    function setAdminContract (address thisAddr) external onlyAuth { admin = Admin(thisAddr);    }

    function Events () public {
        bytes32 empty;
        activeEvents.push(empty);
    }

    /** @dev Creates a new Standard event struct for users to bet on and adds it to the standardEvents mapping.
      * @param name The name of the event to be diplayed.
      * @param startTime The date and time the event begins in the YYYYMMDD9999 format.
      */
    function makeStandardEvent(bytes32 id, bytes32 name, uint startTime) external onlyAuth {
        StandardWagerEvent memory thisEvent;
        thisEvent = StandardWagerEvent( name, startTime, 0, 0, activeEvents.length, emptyBytes32Array, false);
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

    function removeWager (bytes32 eventId, uint value) external onlyAuth {
        standardEvents[eventId].numWagers --;
        standardEvents[eventId].totalAmountBet -= value;
    }

    function addWager(bytes32 eventId, uint value) external onlyAuth {
        standardEvents[eventId].numWagers ++;
        standardEvents[eventId].totalAmountBet += value;
    }

    // TODO allow initialize, buy and sell from Event maybe without wager

    function getActiveEventId (uint i) external view returns (bytes32) { return activeEvents[i]; }

    function getActiveEventsLength () external view returns (uint) { return activeEvents.length; }

    function getStandardEventCount () external view returns (uint) { return eventsCount; }

    function getTotalAmountBet (bytes32 eventId) public view returns (uint) { return standardEvents[eventId].totalAmountBet; }

    function getCancelled(bytes32 id) external view returns (bool) { return standardEvents[id].cancelled; }

    function getStart (bytes32 id) public view returns (uint) { return standardEvents[id].startTime; }

}
