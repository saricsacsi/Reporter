pragma solidity ^0.4.11;

// ================= Ownable Contract start =============================
/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}
// ================= Ownable Contract end ===============================

// ================= Safemath Library start ============================

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
// ================= Safemath Contract end ==============================

// ================= ERC20 Token Contract start =========================
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
// ================= ERC20 Token Contract end ===========================

// ================= Standard Token Contract start ======================
contract StandardToken is ERC20 {
  using SafeMath for uint256;
  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}
// ================= Standard Token Contract end ========================

// ================= Pausable Token Contract start ======================
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
    require (!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require (paused) ;
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
// ================= Pausable Token Contract end ========================

// ================= Reporter Token Contract start =======================
contract ReporterToken is StandardToken, Pausable {
     using SafeMath for uint256;
    // metadata
    string public constant name = "ReporterToken";
    string public constant symbol = "NEWS";
    uint256 public constant decimals = 2;
    string public version = "1.0";
    uint256 public constant INITIAL_SUPPLY = 40000000 * (10 ** uint256(decimals));
    address public TokenDeposit = 0xCf850587D156551a08981F503cdC80e9f278E0D7;      // wallet to token
          
     
    // constructor
  function ReporterToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[TokenDeposit] = INITIAL_SUPPLY;
  }


  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}
// ================= Reporter Token Contract end =======================

// ================= Actual Sale Contract Start ====================
contract ReporterSaleContract is  Ownable,Pausable,ReporterToken {
    using SafeMath for uint256;

    ReporterToken    rep;

    // crowdsale parameters
    uint256 public StartTime = 1507308852;
    uint256 public EndTime   = 1509043252;
    uint256 public totalSupply;
    address public EtherDeposit  = 0xB7f20297F23C12a5b4fd170beE1BB0fc47d1639d;      //  wallet to ether
  
  
    address public TokenDeposit = 0xCf850587D156551a08981F503cdC80e9f278E0D7;      // wallet to token
    address public Address  = 0xaBB711c86375b3142cb7D657F48298d2b3D1Ffb7;  // now the Multisig0102

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 2;                                              // #dp in Indorse contract
    uint256 public Cap;
    uint256 public constant tokenExchangeRate = 1000;                                   // 1000 IND tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions
 
    function ReporterSaleContract() {
        
        Cap = 24000000;
        isFinalized = false;
    }

    event MintREP(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

    function CreateREP(address to, uint256 val) internal returns (bool success){
        MintREP(TokenDeposit,to,val);
        return rep.transferFrom(TokenDeposit,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether 
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
   // require (tokenCreationCap > totalSupply);                                         // CAP reached no more please
      require (now >= StartTime);
      require (now <= EndTime);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

    uint256 weiAmount = _value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(tokenExchangeRate);
                               // check that we're not over totals
     // uint256 checkedSupply = add(totalSupply, tokens);
/** 
 *     require (ind.balanceOf(msg.sender) + tokens <= maxTokens);
      
      // DA 8/6/2017 to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateIND(_beneficiary,tokensToAllocate));                              // Create IND
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
*/
      
      // DA 8/6/2017 end of fair allocation code

  //    totalSupply = checkedSupply;
      require(CreateREP(_beneficiary, tokens));                                         // logs token creation
      EtherDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      EtherDeposit.transfer(this.balance);                                            // send the eth to Indorse multi-sig
    }
}