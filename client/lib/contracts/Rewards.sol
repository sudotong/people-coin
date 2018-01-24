//pragma solidity 0.4.18;
import "../../../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../Admin.sol";
import "../Wagers.sol";
import "../Oracles.sol";

contract Rewards is Ownable {
    mapping (address => bool) private isAuthorized;  
    Admin admin;
    Wagers wagers;
    Oracles oracles;
    mapping(address => int) public playerRep;
    mapping (address => int) public oracleRep;  
    mapping (address => uint) public ethBalance;
    mapping (address => uint) public mvuBalance;
    mapping(address => uint) public unlockedEthBalance;
    mapping (address => uint) public unlockedMvuBalance;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);               
                _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setOraclesContract (address thisAddr) external onlyOwner {
        oracles = Oracles(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setWagersContract (address thisAddr) external onlyOwner {
        wagers = Wagers(thisAddr);        
    }
   
    function getEthBalance(address user) external view returns (uint) {
        return ethBalance[user];
    }

    function getMvuBalance(address user) external view returns (uint) {
        return mvuBalance[user];
    }

    function getUnlockedEthBalance(address user) external view returns (uint) {
        return unlockedEthBalance[user];
    }

    function getUnlockedMvuBalance(address user) external view returns (uint) {
        return unlockedMvuBalance[user];
    }

    function subEth(address user, uint amount) external onlyAuth {
        ethBalance[user] -= amount;
    }

    function subMvu(address user, uint amount) external onlyAuth {
        mvuBalance[user] -= amount;
    }

    function addEth(address user, uint amount) external onlyAuth {
        ethBalance[user] += amount;
    }

    function addMvu(address user, uint amount) external onlyAuth {
        mvuBalance[user] += amount;
    }

    function subUnlockedMvu(address user, uint amount) external onlyAuth {
        unlockedMvuBalance[user] -= amount;
    }

    function subUnlockedEth(address user, uint amount) external onlyAuth {
        unlockedEthBalance[user] -= amount;
    }

    function addUnlockedMvu(address user, uint amount) external onlyAuth {
        unlockedMvuBalance[user] += amount;
    }

    function addUnlockedEth(address user, uint amount) external onlyAuth {
        unlockedEthBalance[user] += amount;
    }
    
    function subOracleRep(address oracle, int value) external onlyAuth {
        oracleRep[oracle] -= value;
    }

    function subPlayerRep(address player, int value) external onlyAuth {
        playerRep[player] -= value;
    }

    function addOracleRep(address oracle, int value) external onlyAuth {
        oracleRep[oracle] += value;
    }

    function addPlayerRep(address player, int value) external onlyAuth {
        playerRep[player] += value;
    }
} 