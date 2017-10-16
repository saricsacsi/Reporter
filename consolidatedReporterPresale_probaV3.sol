pragma solidity ^0.4.12;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
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
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(0X0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}



contract ReporterToken is MintableToken {
  string public name = "Reporter Token";
  string public symbol = "NEWS";
  uint256 public decimals = 18;

  bool public tradingStarted = false;

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. This can not be undone
   */
  function startTrading() onlyOwner {
    tradingStarted = true;
  }


  /**
   * @dev Allows anyone to transfer the Change tokens once trading has started
   * @param _to the recipient address of the tokens.
   * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint _value) hasStartedTrading returns (bool){
    return super.transfer(_to, _value);
  }

  /**
   * @dev Allows anyone to transfer the Change tokens once trading has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) hasStartedTrading returns (bool){
    return super.transferFrom(_from, _to, _value);
  }
}



contract ReporterTokenPresale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  ReporterToken public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  // address where funds are collected
  address public hardwareWallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  // amount of raised tokens 
  uint256 public tokenRaised;

  // minimum contributio to participate in tokensale
  uint256 public minContribution;

  // maximum amount of ether being raised
  uint256 public hardcap;

  // maximum amount of tokens
  uint256 public tokenCreationCap;

  // number of participants in presale
  uint256 public numberOfPurchasers = 0;

  //  for whitelist
  address public cs;

  // switch on/off the authorisation , default: true - on
  bool    public freeForAll = true;

  mapping (address => bool) public authorised; // just to annoy the heck out of americans

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event PreSaleClosed();

  function ReporterTokenPresale() {
    startTimestamp = 1508121458;
    endTimestamp = 1510730048;
    rate = 1000;
    hardwareWallet = 0x006bF2240b8b7F326C8f64631a4f9457A8B5A51d; //wallettoethertest
    token = new ReporterToken();
    minContribution = 0.000001 ether; //9.9 volt
    hardcap = 50000 ether;
   // tokenCreationCap = 24 * 10**6 * 10**18;  // ebben nem vagyok biztos

    //require(startTimestamp >= now);
   // require(endTimestamp >= startTimestamp);
  }

  /**
   * @dev Calculates the amount of bonus coins the buyer gets
   * @param tokens uint the amount of tokens you get according to current rate
   * @return uint the amount of bonus tokens the buyer gets
   */
  function bonusAmmount(uint256 tokens) internal returns(uint256) {
    // first 75000000 tokens get extra 30% of tokens
    if (tokenRaised <= 75000000) {
      return tokens * 3 / 10;
    } else if (tokenRaised > 75000000 && tokenRaised <= 150000000) {
      return tokens * 3 / 20;
    } else {
      return 0;
    }
  }

  // check if valid purchase
  modifier validPurchase {
    require(now >= startTimestamp);
    require(now <= endTimestamp);
    require(msg.value >= minContribution);
    require(weiRaised.add(msg.value) <= hardcap);
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool timeLimitReached = now > endTimestamp;
    bool capReached = weiRaised >= hardcap;
    return timeLimitReached || capReached;
  }


  
    /**
     * @dev throws if person sending is not contract owner or cs role
     */
    modifier onlyCSorOwner() {
        require((msg.sender == owner) || (msg.sender==cs));
        _;
    }

    /**
     * @dev throws if person sending is not authorised or sends nothing
     */
    modifier onlyAuthorised() {
        require (authorised[msg.sender] || freeForAll);
        require (msg.value > 0);
        require (now >= startTimestamp);
        require (now <= endTimestamp);
        require (!(hasEnded()));
        //require(!paused);
        _;
    }

    
    /**
     * @dev authorise an account to participate
     */
    function authoriseAccount(address whom) onlyCSorOwner {
        authorised[whom] = true;
    }

    /**
     * @dev authorise a lot of accounts in one go
     */
    function authoriseManyAccounts(address[] many) onlyCSorOwner {
        for (uint256 i = 0; i < many.length; i++) {
            authorised[many[i]] = true;
        }
    }

    /**
     * @dev ban an account from participation (default)
     */
    function blockAccount(address whom) onlyCSorOwner {
        authorised[whom] = false;
    }

    /**
     * @dev set a new CS representative
     */
    function setCS(address newCS) onlyOwner {
        cs = newCS;
    }
    
    function requireAuthorisation(bool state) {
        freeForAll = !state;
    }

   


  // low level token purchase function
  function buyTokens(address beneficiary) payable validPurchase onlyAuthorised {
    require(beneficiary != 0x0);

    uint256 weiAmount = msg.value;


    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    tokens = tokens + bonusAmmount(tokens);
  
    
    // update state
    weiRaised = weiRaised.add(weiAmount);
    numberOfPurchasers = numberOfPurchasers + 1;
    tokenRaised = tokenRaised.add(tokens);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    hardwareWallet.transfer(msg.value);
  }

  // transfer ownership of the token to the owner of the presale contract
  function finishPresale() public onlyOwner {
    require(hasEnded());
    token.transferOwnership(owner);
    PreSaleClosed();
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

}


