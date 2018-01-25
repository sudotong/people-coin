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

    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier wagerUnlocked (bytes32 wagerId) {
        require (!wagers.getLocked(wagerId));
        _;
    }

    modifier mustBeTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) != address(0));
        _;
    }

    modifier notSettled(bytes32 wagerId) {
        require (!wagers.getSettled(wagerId));
        _;
    }

    modifier checkBalance (uint wagerValue) {
        require (rewards.getUnlockedEthBalance(msg.sender) + msg.value >= wagerValue);
        _;
    }

    modifier notPaused() {
        require (!ppcoin.getContractPaused());
        _;
    }


    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getMaker(wagerId) || msg.sender == wagers.getTaker(wagerId));
        _;
    }

    modifier notTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) == address(0));
        _;
    }

    modifier notMade (bytes32 wagerId) {
        require (wagers.getMaker(wagerId) != address(0));
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
      * @param odds decimal of maker chosen odds * 100.
      */
    function makeWager(bytes32 wagerId, uint value, bytes32 eventId, uint odds) public notMade(wagerId) eventUnlocked(eventId) requireMinWager checkBalance(value) notPaused payable {

        wagers.makeWager( wagerId, value, eventId, odds, msg.sender);
        transferEthToPPC(msg.value);
        ppcoin.addToPlayerFunds(msg.value);
        //events.addWager(eventId, wagerId);
        rewards.addEth(msg.sender, msg.value);
        rewards.subUnlockedEth(msg.sender, (value - msg.value));
    }

    /** @dev Takes a listed wager for a user -- adds address to StandardWager struct.
     * @param id sha3 hash of the msg.sender concat timestamp.
     */
    function takeWager (bytes32 id) public eventUnlocked(wagers.getEventId(id)) wagerUnlocked(id) notPaused payable {
        uint expectedValue = wagers.getOrigValue(id) / (wagers.getOdds(id) / 100);
        require (rewards.getUnlockedEthBalance(msg.sender) + msg.value >= expectedValue);
        address taker = msg.sender;
        transferEthToPPC(msg.value);
        ppcoin.addToPlayerFunds(msg.value);
        rewards.subUnlockedEth(msg.sender, (expectedValue - msg.value));
        rewards.addEth(msg.sender, msg.value);
        wagers.setTaker(id, taker);
        wagers.setLocked(id);
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
        uint odds;
        address maker;
        address taker;
        bool makerCancelRequest;
        bool takerCancelRequest;
        bool locked;
        bool settled;
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

    function makeWager (bytes32 wagerId, uint value, bytes32 eventId, uint odds, address maker) external onlyAuth {
        Wager memory thisWager = Wager (eventId,value,odds,maker,address(0),false,false,false,false);
        wagersMap[wagerId] = thisWager;
    }

    function setLocked (bytes32 wagerId) external onlyAuth { wagersMap[wagerId].locked = true; }

    function setSettled (bytes32 wagerId) external onlyAuth { wagersMap[wagerId].settled = true; }

    function setRefund (address bettor, bytes32 wagerId) external onlyAuth { recdRefund[bettor][wagerId] = true; }

    function setMakerCancelRequest (bytes32 id) external onlyAuth { wagersMap[id].makerCancelRequest = true; }

    function setTakerCancelRequest (bytes32 id) external onlyAuth { wagersMap[id].takerCancelRequest = true; }

    function setTaker (bytes32 wagerId, address taker) external onlyAuth { wagersMap[wagerId].taker = taker; }

    function getEventId(bytes32 wagerId) external view returns (bytes32) { return wagersMap[wagerId].eventId; }

    function getLocked (bytes32 id)  public view returns (bool) { return wagersMap[id].locked; }

    function getSettled (bytes32 id)  public view returns (bool) { return wagersMap[id].settled; }

    function getMaker(bytes32 id)  public view returns (address) { return wagersMap[id].maker; }

    function getTaker(bytes32 id)  public view returns (address) { return wagersMap[id].taker; }

    function getMakerCancelRequest (bytes32 id) external view returns (bool) { return wagersMap[id].makerCancelRequest; }

    function getTakerCancelRequest (bytes32 id) external view returns (bool) { return wagersMap[id].takerCancelRequest; }

    function getRefund (address bettor, bytes32 wagerId) external view returns (bool) { return recdRefund[bettor][wagerId]; }

    function getOdds (bytes32 id) external view returns (uint) { return wagersMap[id].odds; }

    function getOrigValue (bytes32 id) external view returns (uint) { return wagersMap[id].origValue; }

}


contract Rewards is Ownable {
    mapping (address => bool) private isAuthorized;
    Admin admin;
    Wagers wagers;
    mapping (address => uint) public ethBalance;
    mapping (address => uint) public peepBalance;
    mapping(address => uint) public unlockedEthBalance;
    mapping (address => uint) public unlockedPeepBalance;

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

    function getUnlockedEthBalance(address user) external view returns (uint) { return unlockedEthBalance[user]; }

    function getUnlockedPeepBalance(address user) external view returns (uint) { return unlockedPeepBalance[user]; }

    function subEth(address user, uint amount) external onlyAuth { ethBalance[user] -= amount; }

    function subPeep(address user, uint amount) external onlyAuth { peepBalance[user] -= amount; }

    function addEth(address user, uint amount) external onlyAuth { ethBalance[user] += amount; }

    function addPeep(address user, uint amount) external onlyAuth { peepBalance[user] += amount; }

    function subUnlockedPeep(address user, uint amount) external onlyAuth { unlockedPeepBalance[user] -= amount; }

    function subUnlockedEth(address user, uint amount) external onlyAuth { unlockedEthBalance[user] -= amount; }

    function addUnlockedPeep(address user, uint amount) external onlyAuth { unlockedPeepBalance[user] += amount; }

    function addUnlockedEth(address user, uint amount) external onlyAuth { unlockedEthBalance[user] += amount; }
}






contract PPC is Ownable {

    address peepWallet;
    Events events;
    Admin admin;
    Wagers wagers;
    Rewards rewards;
    PeepCoin peepCoins;

    bool  contractPaused = false;
    bool  randomNumRequired = false;
    bool settlementPeriod = false;
    uint lastIteratedIndex = 0;
    uint  peepBalance = 0;
    uint  lotteryBalance = 0;
    uint serviceFee = 3; //Percent
    //  TODO: Set equal to launch date + one month in unix epoch seocnds
    uint  newMonth = 1515866437;
    uint  monthSeconds = 2592000;
    uint public playerFunds;

    mapping (bytes32 => bool) validIds;
    mapping (address => bool) abandoned;
    mapping (address => bool) private isAuthorized;

    modifier notPaused() {
        require (!contractPaused);
        _;
    }

    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getMaker(wagerId) || msg.sender == wagers.getTaker(wagerId));
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


    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier wagerUnlocked (bytes32 wagerId) {
        require (!wagers.getLocked(wagerId));
        _;
    }

    modifier mustBeVoteReady(bytes32 eventId) {
        require (events.getVoteReady(eventId));
        _;
    }

    modifier mustBeTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) != address(0));
        _;
    }

    modifier notSettled(bytes32 wagerId) {
        require (!wagers.getSettled(wagerId));
        _;
    }

    function () payable public {
        if (msg.sender != address(wagers)) {
            peepBalance += msg.value;
        }
    }

    // Constructor
    function PPC () payable public {
        peepWallet = msg.sender;
        peepCoins = PeepCoin(0x10f5125ECEdd1a0c13de969811A8c8Aa2139eCeb); //TODO: Update with actual token address
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
        require (rewards.getUnlockedEthBalance(msg.sender) >= eth);
        rewards.subUnlockedEth(msg.sender, eth);
        rewards.subEth(msg.sender, eth);
        playerFunds -= eth;
        msg.sender.transfer(eth);
        require (rewards.getUnlockedPeepBalance(msg.sender) >= peep);
        rewards.subUnlockedPeep(msg.sender, peep);
        rewards.subPeep(msg.sender, peep);
        peepCoins.transfer (msg.sender, peep);

    }


    /** @dev Settles the wager if both the maker and taker have voted, pays out if they agree
      * @param wagerId bytes32 id for the wager.
      */
    function settle(bytes32 wagerId) internal {
        address maker = wagers.getMaker(wagerId);
        address taker = wagers.getMaker(wagerId);
        uint origValue = wagers.getOrigValue(wagerId);
        rewards.addEth(maker, origValue);
        rewards.subEth(taker, origValue);
        payout(wagerId, maker); // TODO wrong payout atm
    }

    /** @dev Pays out the wager if both the maker and taker have agreed
       * @param wagerId bytes32 id for the wager.
       */
    function payout(bytes32 wagerId, address user) internal {
        if (!wagers.getSettled(wagerId)) {
            wagers.setSettled(wagerId);
            uint origVal =  wagers.getOrigValue(wagerId);
            bool tie = false;
            if (tie) { //Tie
                msg.sender.transfer(origVal);

            } else {
                uint payoutValue = 90; // TODO get amount
                uint fee = (payoutValue/100) * 2; // Sevice fee is 2 percent

                peepBalance += (3*(fee/4));
                rewards.subEth(user, payoutValue);
                payoutValue -= fee;
                lotteryBalance += (fee/8);

                // TODO check who we are transferring it tot
                transferEthFromPPC(user, payoutValue);
            }
            wagers.setLocked(wagerId);
        }
    }



    // PLayers should call this when an event has been cancelled after thay have made a wager
    function playerRefund (bytes32 wagerId) external onlyBettor(wagerId) {
        require (events.getCancelled(wagers.getEventId(wagerId)));
        require (!wagers.getRefund(msg.sender, wagerId));
        wagers.setRefund(msg.sender, wagerId);
        address maker = wagers.getMaker(wagerId);
        wagers.setSettled(wagerId);
        if(msg.sender == maker) {
            // TODO refund amount
            rewards.addUnlockedEth(maker, 90);
        }
    }

    /** @dev Pays out the monthly lottery balance to a random  and sends the peepWallet its accrued balance.
    */
    function payoutFunds(address toPay) private {
        // can use this function to do transfers
        if (peepCoins.balanceOf(toPay) > 0) {
            uint thisWin = lotteryBalance;
            lotteryBalance = 0;
            toPay.transfer(thisWin);
        } else {

        }
        assert(this.balance - peepBalance > playerFunds);
        peepWallet.transfer(peepBalance);
        peepBalance = 0;
    }

    function pauseContract() public onlyOwner { contractPaused = true; }

    function addPPCBalance (uint amount) public onlyAuth { peepBalance += amount; }

    function addToPlayerFunds (uint amount) public onlyAuth { playerFunds += amount; }

    function subFromPlayerFunds (uint amount) public onlyAuth { playerFunds -= amount; }

    function getContractPaused() public constant returns (bool) { return contractPaused; }

    function transferTokensToPPC (address player, uint peepStake) internal { peepCoins.transferFrom(player, this, peepStake); }

    function transferTokensFromPPC (address player, uint peepStake) internal { peepCoins.transfer(player, peepStake); }

    function transferEthFromPPC (address recipient, uint amount) internal { recipient.transfer(amount); }

    function addMonth () internal { newMonth += monthSeconds; }

    function getNewMonth () public constant returns (uint256) { return newMonth; }

}


contract Events is Ownable {
    mapping (address => bool) private isAuthorized;
    uint public eventsCount;
    bytes32[] public activeEvents;

    Wagers wagers;
    Admin admin;


    struct StandardWagerEvent {
        bytes32 name;
        bytes32 teamOne;
        uint startTime; // Unix timestamp
        uint numWagers;
        uint totalAmountBet;
        uint activeEventIndex;
        bytes32[] wagers;
        bool voteReady;
        bool locked;
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
      * @param teamOne The name of one of the participants, eg. Toronto Maple Leafs, Georges St-Pierre, Justin Trudeau.
      */
    function makeStandardEvent(
        bytes32 id,
        bytes32 name,
        uint startTime,
        bytes32 teamOne
    )
    external
    onlyAuth
    {
        StandardWagerEvent memory thisEvent;
        thisEvent = StandardWagerEvent( name,
            teamOne,
            startTime,
            0,
            0,
            activeEvents.length,
            emptyBytes32Array,
            false,
            false,
            false);
        standardEvents[id] = thisEvent;
        eventsCount++;
        activeEvents.push(id);
    }

    function updateStandardEvent(
        bytes32 eventId,
        uint newStartTime,
        bytes32 newTeamOne
    )
    external
    onlyAuth
    {
        standardEvents[eventId].startTime = newStartTime;
        standardEvents[eventId].teamOne = newTeamOne;

    }

    function cancelStandardEvent (bytes32 eventId) external onlyAuth {
        standardEvents[eventId].voteReady = true;
        standardEvents[eventId].locked = true;
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


    function setLocked (bytes32 eventId) public onlyAuth { standardEvents[eventId].locked = true; }

    function getActiveEventId (uint i) external view returns (bytes32) { return activeEvents[i]; }

    function getActiveEventsLength () external view returns (uint) { return activeEvents.length; }

    function getStandardEventCount () external view returns (uint) { return eventsCount; }

    function getTotalAmountBet (bytes32 eventId) public view returns (uint) { return standardEvents[eventId].totalAmountBet; }

    function getCancelled(bytes32 id) external view returns (bool) { return standardEvents[id].cancelled; }

    function getStart (bytes32 id) public view returns (uint) { return standardEvents[id].startTime; }

    function getLocked(bytes32 id) public view returns (bool) { return standardEvents[id].locked; }

    function getVoteReady (bytes32 id) external view returns (bool) { return standardEvents[id].voteReady; }

    function makeVoteReady (bytes32 id) internal { standardEvents[id].voteReady = true; }

}
