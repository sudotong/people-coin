pragma solidity ^0.4.18;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";


/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract PeepCoin is StandardToken {

    string public constant name = "PeepCoin"; // solium-disable-line uppercase
    string public constant symbol = "PPC"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function PeepCoin() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

}

contract Admin is Ownable {
    mapping (address => bool) private isAuthorized;
    uint minWagerAmount = 10;
    uint callbackInterval = 15;
    uint callbackGasLimit = 600000;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) public onlyOwner { isAuthorized[nowAuthorized] = true; }

    function removeAuthority (address unauthorized) public onlyOwner { isAuthorized[unauthorized] = false; }

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

    function getCallbackGasLimit() external view returns (uint) { return callbackGasLimit; }

}