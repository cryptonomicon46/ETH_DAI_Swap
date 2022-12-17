
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IPersyToken.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract FusionToken is IFusionToken {

    using SafeMath for uint;
    string private _name= "PERSEVERENCE";
    string private _symbol = "PERSY";
    uint private _decimal = 18;
    address private _owner;
    uint private _totalSupply = 1000;
    mapping (address => uint) private _balance;
    mapping (address => mapping (address => uint)) private _allowances;

    constructor ()
    {       
        require(msg.sender != address(0),"OWNER_ERROR");
        _owner = msg.sender;
        _mint(_owner,_totalSupply);     
    }

    modifier onlyOwner(address checkOwner) {
        require(_owner == checkOwner,"Caller is not the owner");
        _;
    }

    /// @notice totalSupply returns the total supply of the minted Fusion Token
    ///
        function totalSupply() external view override returns (uint) {
            return _totalSupply;
        }

    function decimal() external view override returns (uint) {
        return _decimal;
    }

    function balanceOf(address owner) external view override returns (uint) {
        return _balance[owner];
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint) {
        return _allowances[owner][spender];
    }
   
    /// @notice _mint, will mint tokens for the account and updates balances, emits Transfer event
    /// @param account, account that'll receive the minted tokens
    /// @param amount , minted amount
    function _mint(address account, uint amount) internal virtual onlyOwner(msg.sender) {
        require(account != address(0),"INVALID_ADDRESS");
        require (amount<= _totalSupply,"INVALID_MINT_AMOUNT");
         _balance[account] = _balance[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
    }

    /// @notice _burn, will burn tokens from the account, updates balances and emits Transfer event
    /// @param account that'll lose the tokens on burn
    /// @param amount , the amount of tokens to be burned
    function _burn(address account, uint amount) internal virtual onlyOwner(msg.sender) {
        require(account != address(0),"INVALID_ACCOUNT");
        require(_balance[account]>= amount, "INSUFFICIENT_BALANCE_TO_BURN");
        _balance[account] = _balance[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
    }

    /// @notice transferFrom, sends the allowance amount alloted to msg.sender on behalf of owner to the recipeient, emits Transfer event. 
    /// @param recipient  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev calls the internal _transfer function , adjusts the allowance, emits Transfer and Approval events.
    function transferFrom(
        address owner,
        address recipient,
        uint amount
    ) external  override returns (bool) {
        _transfer(owner,recipient,amount);
        _approve(owner, msg.sender, _allowances[owner][msg.sender].sub(amount));
        return true;
    }

    /// @notice transfer, sends amount to recipient, emits Transfer event. 
    /// @param recipient  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev checks balances of sender >= amount, checks of recipent != zero address
    function transfer(
        address recipient,
        uint amount
    ) external  override returns (bool) {
        _transfer(msg.sender,recipient,amount);
        return true;
    }


    /// @notice _transfer, internal function that handles sending amount to recipient, emits Transfer event. 
    /// @param recipient  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev checks balances of sender >= amount, checks of recipent != zero address, adjusts the balances and emits the Transfer event
    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal {
        require(_balance[sender] >= amount,"INSUFFICIENT_FOR_TRANSFER");
        require(recipient != address(0),"INVALID_RECIPIENT");
        _balance[sender].sub(amount);
        _balance[recipient].add(amount);
        emit Transfer(recipient,amount, 0);
         }



    /// @notice approve, sets approval for the spender on behalf on msg.sender for amount
    /// @param spender  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev emits an approval event
    function approve(
        address spender,
        uint amount
    ) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /// @notice _approve, internal function that handles the approval for the spender on behalf on owner for amount
    /// @param owner  owner of the funds
    /// @param spender  spender seeking an allowance on behalf of the owner
    /// @param amount the allowance amount
      function _approve(
        address owner,
        address spender,
        uint amount
    ) internal  {
        require(owner != address(0),"INVALID_OWNER_ADDRESS");
        require(spender != address(0),"INVALID_SPENDER_ADDRESS");
        _allowances[owner][spender] = amount;
        emit Approval(owner,spender,amount);
    }

}