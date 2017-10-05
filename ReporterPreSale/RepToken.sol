pragma solidity ^0.4.11;


import './StandardToken.sol';



/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract RepToken is StandardToken {

  string public constant name = "ReporterToken";
  string public constant symbol = "NEWS";
  uint8 public constant decimals = 2;

  uint256 public constant INITIAL_SUPPLY = 400 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function RepToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}