
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IFusionToken.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract FusionToken is IFusionToken {

    using SafeMath for uint;
    string private _name= "Fusion";
    string private _symbol = "ION";
    uint private _decimal = 18;
    address private _owner;
    uint private _totalSupply = 100000;
    mapping (address => uint) private _balance;
    mapping (address => mapping (address => uint)) private _allowances;

    constructor ()
    {       
        require(msg.sender != address(0),"OWNER_ERROR");
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(_owner == msg.sender,"Caller is not the owner");
        _;
    }

    /// @notice totalSupply returns the total supply of the minted Fusion Token
        function totalSupply() external view override returns (uint) {
            return _totalSupply;
        }

    function decimal() external view override returns (uint) {
        return _decimal;
    }

    ///@notice balanceOf: returns the owner of the contract 
    /// @param account: check balance of this account
    function balanceOf(address account) external view override returns (uint) {
        return _balance[account];
    }

    ///@notice name: returns the name of the token
    function name() external view override returns (string memory) {
        return _name;
    }

    ///@notice symbol: returns the symbol associated with the token
    function symbol() external view override returns (string memory) {
        return _symbol;
    }


    ///@notice owner: returns the owner of the contract 
    function owner() external view returns (address) {
        return _owner;
    }

    function allowance(
        address spender
    ) external view override returns (uint) {
        return _allowances[_owner][spender];
    }
   
    /// @notice mint, external mint function, mints tokens to the owner's account
    /// @param amount , minted amount
    /// @return bool, true if the operation succeeds
    function mint(uint amount) external onlyOwner returns (bool) {
        _mint(amount);
        return true;
    }
    /// @notice _mint, internal function that handles the mint operation, checks, events to the owner
    /// @param amount , minted amount
    function _mint(uint amount) internal virtual  {
        require (amount<= _totalSupply,"INVALID_MINT_AMOUNT");
         _balance[_owner] = _balance[_owner].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(_owner,amount );
    }

    /// @notice burn, external burn function, will burn tokens from the owner's account
    /// @param amount , the amount of tokens to be burned
    /// @return boolean, returns true if the operation succeeds
    function burn(uint amount) external onlyOwner returns (bool) {
        _burn(amount);
        return true;
    }

    /// @notice _burn, internal burn function, handles the events and checks before burning tokesn from owner's account
    /// @param amount , the amount of tokens to be burned
    function _burn(uint amount) internal virtual {
        require(_balance[_owner]>= amount, "INSUFFICIENT_BALANCE_TO_BURN");
        _balance[_owner] = _balance[_owner].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(address(0),amount );

    }

    /// @notice transferFrom, sends the allowance amount alloted to msg.sender on behalf of owner to the recipeient, emits Transfer event. 
    /// @param recipient  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev calls the internal _transfer function , adjusts the allowance, emits Transfer and Approval events.
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        _transfer(sender,recipient,amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
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
        _balance[sender]= _balance[sender].sub(amount);
        _balance[recipient]= _balance[recipient].add(amount);
        emit Transfer(recipient,amount);
         }



    /// @notice approve, sets approval for the spender on behalf on msg.sender for amount
    /// @param spender  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev emits an approval event
    function approve(
        address spender,
        uint amount
    ) external override onlyOwner returns (bool) {
        _approve(_owner, spender, amount);
        return true;
    }

    /// @notice _approve, internal function that handles the approval for the spender on behalf on owner for amount
    /// @param account  owner of the funds
    /// @param spender  spender seeking an allowance on behalf of the owner
    /// @param amount the allowance amount
      function _approve(
        address account,
        address spender,
        uint amount
    ) internal  {
        require(account != address(0),"INVALID_OWNER_ADDRESS");
        require(spender != address(0),"INVALID_SPENDER_ADDRESS");
        _allowances[account][spender] = amount;
        emit Approval(account,spender,amount);
    }



}