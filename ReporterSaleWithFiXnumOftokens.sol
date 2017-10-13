pragma solidity ^0.4.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
}
/**
 * @title ReporterToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract ReporterToken is StandardToken {

  string public constant name = "ReporterToken";
  string public constant symbol = "NEWS";
  uint8 public constant decimals = 2;

  uint256 public constant INITIAL_SUPPLY = 40000000 * (10 ** uint256(decimals));
  address public ReporterDeposit  = 0xCf850587D156551a08981F503cdC80e9f278E0D7 ;
  //address public ReporterDeposit  = 0xCf850587D156551a08981F503cdC80e9f278E0D7 ;      // deposit address now wallettotoken
  
 
   
  function ReporterToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[ReporterDeposit] = 24000000 * (10 ** uint256(decimals));
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
contract Presale is Ownable,Pausable,ReporterToken{
  using SafeMath for uint256;

 
  bool public freeForAll = true;    // The token being sold
  bool public saleFinished;
  ReporterToken public token;  // ??? here will be the  token address
 address public ReporterDeposit  = 0xCf850587D156551a08981F503cdC80e9f278E0D7 ;
    
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime = 1507308852;
//now 10.06 23.13


  uint256 public stopTime = 1509043252; 
  // Human time (GMT): 2017. October 26., Thursday 18:40:52
  //Human time (your time zone): 2017. október 26., csütörtök 20:40:52 GMT+02:00

  // address where funds are collected
  address public wallet = 0xB7f20297F23C12a5b4fd170beE1BB0fc47d1639d;//  wallet to ether
// owners: 009ecd6b08d0798c10f491c78d6d0d6e9c600919 AND 004c2db4e3721c6bf5edb49767ef003ecb68e00a

  // how many token units a buyer gets per wei
  uint256 public rate = 1000;

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


  function Presale() {
    require(startTime <= now);
    require(stopTime >= startTime);
    require(rate > 0);
    require(wallet != 0x0);

    token = createTokenContract();  // ha meglévő token addresse kerül be akkor ez as or nem kell talán
  
  }



  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (ReporterToken) {
    return new ReporterToken();
  }
   
  function supply() internal returns (uint256) {
        return balances[ReporterDeposit];
    }

  function getCurrentTimestamp() internal returns (uint256) {
        return now;
    }

  function getRateAt(uint256 at) constant returns (uint256) {
        if (at < startTime) {
            return 0;
        } else if (at < (startTime + 7 days)) {
            return 2000;
        } else if (at < (startTime + 14 days)) {
            return 1500;
        } else if (at <= stopTime) {
            return 1000;
        } else {
            return 0;
        }
    }

  // fallback function can be used to buy tokens
  function () payable onlyAuthorised{
    buyTokens(msg.sender,msg.value);
  }

  // low level token purchase function
  function buyTokens(address beneficiary, uint256 weiAmount) internal {
    require(beneficiary != 0x0);
    require(validPurchase());
  

       // calculate token amount to be created

   // uint256 actualRate = getRateAt(getCurrentTimestamp()); 
    uint256 tokens = 5000000;
   
    // update state
    weiRaised = weiRaised.add(weiAmount);
    deposits[msg.sender] += msg.value;


    require(supply() >= tokens);

    balances[ReporterDeposit] = balances[ReporterDeposit].sub(tokens);
    balances[beneficiary] = balances[beneficiary].add(tokens);

       
    //TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

// here is the problem somewhere  IF I WRITE HERE ANYTHING I AM GOING TO BUD INSTRACTIONS
   // require(supply() >= tokens);

   // balances[ReporterDeposit] = balances[ReporterDeposit].sub(tokens);
   // balances[beneficiary] = balances[beneficiary].add(tokens);
  
   //  token.transfer(beneficiary,tokens);
  

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal returns (bool) {
    bool withinPeriod = now >= startTime && now <= stopTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
 
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > stopTime;
  }


}