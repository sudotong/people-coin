//pragma solidity 0.4.18;
import "./Events.sol";
import "./OracleVerifier.sol";
import "./Rewards.sol";
import "node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./MvuToken.sol";
import "./Wagers.sol";
import "./Mevu.sol";

contract OraclesController is Ownable {
    Events events;
    OracleVerifier oracleVerif;
    Rewards rewards;
    Admin admin;
    Wagers wagers;
    MvuToken mvuToken;
    Mevu mevu;
    Oracles oracles;

    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier eventLocked (bytes32 eventId){
        require (events.getLocked(eventId));
        _;
    }

    modifier onlyOracle (bytes32 eventId) {
        require (oracles.checkOracleStatus(msg.sender, eventId));
        _;
    }

    modifier onlyVerified() {
        require (oracleVerif.checkVerification(msg.sender));
        _;
    }

    modifier mustBeAllowed (bytes32 eventId) {
        require (oracles.getAllowed(eventId, msg.sender));
        _;
    }

    modifier mustBeVoteReady(bytes32 eventId) {
        require (events.getVoteReady(eventId));
        _;           
    }

    modifier notClaimed (bytes32 eventId) {
        require (!oracles.getPaid(eventId, msg.sender));
        _;
    }

    function setOracleVerifContract (address thisAddr) external onlyOwner {
        oracleVerif  = OracleVerifier(thisAddr);
    }

    function setRewardsContract   (address thisAddr) external onlyOwner {
        rewards = Rewards(thisAddr);
    }
    
    function setEventsContract (address thisAddr) external onlyOwner {
        events = Events(thisAddr);        
    }  

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setMvuTokenContract (address thisAddr) external onlyOwner {
        mvuToken = MvuToken(thisAddr);
    }

    function setMevuContract (address thisAddr) external onlyOwner {
        mevu = Mevu(thisAddr);
    }

    /** @dev Registers a user as an Oracle for the chosen event. Before being able to register the user must
      * allow the contract to move their MVU through the Token contract.                
      * @param eventId int id for the standard event the oracle is registered for.
      * @param mvuStake Amount of mvu (in lowest base unit) staked. 
      * @param winnerVote uint of who they voted as winning             
    */
    function registerOracle (          
    bytes32 eventId,
    uint mvuStake,
    uint winnerVote
    ) 
        eventUnlocked(eventId) 
        onlyVerified          
        mustBeVoteReady(eventId)
        mustBeAllowed(eventId) 
    {
        //require (keccak256(strConcat(addrToString(msg.sender),  bytes32ToString(eventId))) == oracleId);       
        require(mvuStake >= admin.getMinOracleStake());
        require(winnerVote == 1 || winnerVote == 2 || winnerVote == 3);            
        bytes32 empty;
        if (oracles.getLastEventOraclized(msg.sender) == empty) {
            oracles.addToOracleList(msg.sender);                
        }
        oracles.setLastEventOraclized(msg.sender, eventId) ;
        transferTokensToMevu(msg.sender, mvuStake);    
        if (oracles.getMvuStake(eventId, msg.sender) == 0) {
            oracles.addOracle (msg.sender, eventId, mvuStake, winnerVote);                  
            rewards.addMvu(msg.sender, mvuStake);          
        }                 
    }

    // Called by oracle to get paid after event voting closes
    function claimReward (bytes32 eventId )
        onlyOracle(eventId)
        notClaimed(eventId)
        eventLocked(eventId)
    {
        oracles.setPaid(msg.sender, eventId);
        uint ethReward;
        uint mvuReward;
        uint mvuRewardPool;
        if (events.getWinner(eventId) == 1) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForOne(eventId); 
        } 
        if (events.getWinner(eventId) == 2) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForTwo(eventId); 
        }         
        if (events.getWinner(eventId) == 3) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForThree(eventId); 
        } 
        
        uint twoPercentRewardPool = 2 * events.getTotalAmountResolvedWithoutOracles(eventId)/100;
        uint threePercentRewardPool = 3 * (events.getTotalAmountBet(eventId) - events.getTotalAmountResolvedWithoutOracles(eventId))/100;
        uint totalRewardPool = (threePercentRewardPool/12) + (threePercentRewardPool/3) + (twoPercentRewardPool/8);
        uint stakePercentageTimesTen = 1000 * oracles.getMvuStake(eventId, msg.sender);
        stakePercentageTimesTen /= oracles.getTotalOracleStake(eventId);

        if (oracles.getWinnerVote(eventId, msg.sender) == events.getWinner(eventId)) {
            ethReward = (totalRewardPool/1000) * stakePercentageTimesTen;
            rewards.addUnlockedEth(msg.sender, ethReward);             
            rewards.addEth(msg.sender, ethReward);

            mvuReward = (mvuRewardPool/1000) * stakePercentageTimesTen;
            rewards.addMvu(msg.sender, mvuReward);
            mvuReward += oracles.getMvuStake(eventId, msg.sender);
            rewards.addUnlockedMvu(msg.sender, mvuReward);
           
            
            
        } else {
            mvuReward = oracles.getMvuStake(eventId, msg.sender)/2;
            rewards.subMvu(msg.sender, mvuReward);
            rewards.addUnlockedMvu(msg.sender, mvuReward);
            rewards.subOracleRep(msg.sender, admin.getOracleRepPenalty());
        }


    }

    // called by oracle to get refund if not enough oracles register and oracle settlement is cancelled
    function claimRefund (bytes32 eventId) {
        

    }

   

    function transferTokensToMevu (address oracle, uint mvuStake) internal {
        mvuToken.transferFrom(oracle, address(mevu), mvuStake);       
    }




}