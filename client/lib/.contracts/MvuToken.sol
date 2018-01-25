pragma solidity ^0.4.18;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * @title MvuToken
 * @dev Mintable ERC20 Token which also controls a one-time bet contract, token transfers locked until sale ends.
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */


contract MvuToken is MintableToken {
    event TokensMade(address indexed to, uint amount);
    uint  saleEnd = 1519022651; // TODO: Update with actual date
    uint betsEnd = 1519000651;  // TODO: Update with actual date
    uint tokenCap = 100000000; // TODO: Update with actual cap

    mapping (address => uint) private balances;

    modifier saleOver () {
        require (now > saleEnd);
        _;
    }


    modifier betsAllowed () {
        require (now < betsEnd);
        _;
    }

    modifier underCap (uint tokens) {
        require(totalSupply() + tokens < tokenCap);
        _;
    }

    function MvuToken (uint initFounderSupply) public {
        balances[msg.sender] = initFounderSupply;
        TokensMade(msg.sender, initFounderSupply);
        mint(msg.sender, initFounderSupply);
    }

    function transfer (address _to, uint _value) saleOver public returns (bool) {
        super.transfer(_to, _value);
    }

    function mint(address _to, uint _amount) onlyOwner canMint underCap(_amount) public returns (bool) {
        super.mint(_to, _amount);
    }


}

contract Admin is Ownable {
    mapping (address => bool) private isAuthorized;
    uint minWagerAmount = 10;
    uint callbackInterval = 15;
    uint minOracleStake = 1;
    uint callbackGasLimit = 600000;
    int oracleRepPenalty = 25;
    mapping (bytes32 => uint) minOracleNum;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

    function setMinOracleStake (uint newMin) external onlyOwner { minOracleStake = newMin; }

    function setMinOracleNum (bytes32 eventId, uint min) external onlyAuth { minOracleNum[eventId] = min; }

    function setOracleRepPenalty (int penalty) external onlyOwner { oracleRepPenalty = penalty; }

    function setCallbackGasLimit (uint newLimit) external onlyOwner { callbackGasLimit = newLimit; }

    /** @dev Sets a new number for the interval in between callback functions.
      * @param newInterval The new interval between oraclize callbacks.
      */
    function setCallbackInterval(uint newInterval) external onlyOwner { callbackInterval = newInterval; }

    /** @dev Updates the minimum amount of ETH required to make a wager.
      * @param minWager The new required minimum amount of ETH to make a wager.
      */
    function setMinWagerAmount(uint256 minWager) external onlyOwner { minWagerAmount = minWager; }

    function getCallbackInterval() external view returns (uint) { return callbackInterval; }

    function getMinWagerAmount() external view returns (uint) { return minWagerAmount; }

    function getMinOracleStake () external view returns (uint) {
        return minOracleStake;
    }

    function getCallbackGasLimit() external view returns (uint) {
        return callbackGasLimit;
    }

    function getMinOracleNum (bytes32 eventId) external view returns (uint) {
        return minOracleNum[eventId];
    }


}