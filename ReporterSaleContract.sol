pragma solidity ^0.4.11;


//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Start of general part (Ownable,Pausable,ERC20,ERC20Basic,BasicToken, StandardToken) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


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

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX End of general part (Ownable,Pausable,ERC20,ERC20Basic,BasicToken, StandardToken) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Special part from here (token definition, sale Contarct )xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


contract ReporterToken is StandardToken, Ownable, Pausable {
    using SafeMath for uint256;

    // Public variables of the token   
  string public constant name = "ReporterToken";
  string public constant symbol = "NEWS";
  uint256 public constant decimals = 2;
  uint256 public constant INITIAL_SUPPLY = 40000000 * (10 ** uint256(decimals));

  address public home = 0x2E8f862707634bC9D90F87992c410702e9280547; // multisig test wallet

  
 
   
  function ReporterToken() {
   
    totalSupply = INITIAL_SUPPLY;
    balances[home] = INITIAL_SUPPLY;
  }                        
    }


 // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


contract ReporterSaleContract is Ownable, Pausable, ReporterToken {
    using SafeMath for uint256;

  bool public freeForAll = true;    // you can switch off/on here to test 
  bool public saleFinished;

  ReporterToken public token;  //  here will be the  token address if I have existing Token
  address public ReporterDeposit  = 0xCf850587D156551a08981F503cdC80e9f278E0D7 ;

  // current amount of tokens what we would like to sell  ( the totalSupply : 40.000.000 )
  uint256 currentLimit = 24000000 * (10 ** uint256(decimals));
     
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime = 1507308852; // Human time (GMT): 2017. October 6., 
  uint256 public stopTime = 1509043252;  // Human time (GMT): 2017. October 26., 

  // address where funds are collected
  address public wallet = 0xB7f20297F23C12a5b4fd170beE1BB0fc47d1639d;//   now is the Wallet to ether  later : multisig wallet
  
  // how many token units a buyer gets per wei  -- we dont use now, we have different rate depends on the time
  // uint256 public rate = 1000;

  // amount of raised money in wei  1 ether = 10**18 wei
  uint256 public weiRaised;

  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

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


    function supply() internal returns (uint256) {
        return balances[ReporterDeposit];

    }  

 /* Initializes contract with initial supply tokens to the creator of the contract */
    function ReporterSaleContract()  {
         balances[ReporterDeposit] = currentLimit;
         balances[home] = totalSupply.sub(currentLimit);
                  
    }

    function () payable onlyAuthorised{
    buyTokens(msg.sender,msg.value);
  }

  // low level token purchase function
  function buyTokens(address beneficiary, uint256 weiAmount) internal {
    require(beneficiary != 0x0);
 

    // calculate token amount to be created
    uint256 actualRate = getRateAt(getCurrentTimestamp()); 
    uint256 tokens = weiAmount.mul(actualRate);

    require(supply() >= tokens);
   
    // update state
    weiRaised = weiRaised.add(weiAmount);
    deposits[msg.sender] += msg.value;


    token.transfer(msg.sender, tokens);              // makes the transfers
       
    TokenPurchase(beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }


  function finalize() onlyOwner {
        require(!saleActive());

        // Transfer the rest of token to Cobinhood
        balances[home] = balances[home].add(balances[ReporterDeposit]);
        
    }

    function saleActive() public constant returns (bool) {
        return (getCurrentTimestamp() >= startTime &&
                getCurrentTimestamp() < stopTime && supply() > 0);
   }
 }


