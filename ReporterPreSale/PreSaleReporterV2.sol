pragma solidity ^0.4.11;

import './RepToken.sol';
import './SafeMath.sol';
import './Ownable.sol';






/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Presale is Ownable,Pausable{
  using SafeMath for uint256;

 
  bool public freeForAll = true;    // The token being sold
  bool    public saleFinished;
  RepToken public token;  // ide jön a token address

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public stopTime;

  // address where funds are collected
  address public wallet;  // majd ide jön a multisig wallett cím
// pl. address public wallet = 0x......



  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  // from DA simplecontract to create an array for the authorised users addresses
  // and for the amounts what they sent
    mapping (address => uint256) public deposits;
    mapping (address => bool) public authorised; 

 /**
     * @dev throws if person sending is not authorised or sends nothing
     */
    modifier onlyAuthorised() {
        require (authorised[msg.sender] || freeForAll);
        require (msg.value > 0);
        require (now >= startTime);
        require (now <= stopTime);
        require (!saleFinished);
        require(!paused);
        _;
    }

     /**
     * @dev authorise an account to participate
     */
    function authoriseAccount(address whom) onlyOwner {
        authorised[whom] = true;
    }

    /**
     * @dev authorise a lot of accounts in one go
     */
    function authoriseManyAccounts(address[] many) onlyOwner {
        for (uint256 i = 0; i < many.length; i++) {
            authorised[many[i]] = true;
        }
    }

    /**
     * @dev ban an account from participation (default)
     */
    function blockAccount(address whom) onlyOwner {
        authorised[whom] = false;
    }

    function requireAuthorisation(bool state) {
        freeForAll = !state;
    }

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Presale(uint256 _startTime, uint256 _stopTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_stopTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();  // ha meglévő token addresse kerül be akkor ez as or nem kell talán
    startTime = _startTime;
    stopTime = _stopTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (RepToken) {
    return new RepToken();
  }


  // fallback function can be used to buy tokens
  function () payable onlyAuthorised{
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    //token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= stopTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > stopTime;
  }


}