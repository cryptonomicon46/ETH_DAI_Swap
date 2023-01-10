
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";


/// @title FusionToken contract mints ION tokens to the owner to create a UniSwapV3 pool later on
/// @author Sandip Nallani
/// @notice This will be used to create an ION/DAI pool on Uniswap V3
/// @dev Some kind of ETH to DAI swap to be implemented using the ION/DAI pool 
contract FusionToken is IERC20 {

    using SafeMath for uint;
    string private _name= "Fusion";
    string private _symbol = "ION";
    uint private _decimal = 18;
    address private _owner;
    uint private _totalSupply;
    mapping (address => uint) private _balance;
    mapping (address => mapping (address => uint)) private _allowance;

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
    ///@return uint256 amount of the balance
    function balanceOf(address account) external view override returns (uint256) {
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

    ///@notice allowance: returns the allowance for the spender on behalf of the owner\
    ///@param account: the owner account
    ///@param spender: the spender account
    ///@return uint: the allowance amount
    function allowance(
        address account,
        address spender
    ) external view override returns (uint) {
        return _allowance[account][spender];
    }
   
    /// @notice mint, external mint function, mints tokens to the owner's account
    ///@param account, the account that received the minted tokens
    /// @param amount , minted amount
    /// @return bool, true if the operation succeeds
    function mint(address account,uint amount) external override onlyOwner returns (bool) {
        _mint(account,amount);
        return true;
    }
    /// @notice _mint, internal function that handles the mint operation, checks, events to the owner
    /// @param account, receiver of the tokens
    /// @param amount , amount of tokens minted
    function _mint(address account,uint amount) internal virtual  {
        // require (amount<= _totalSupply,"INVALID_MINT_AMOUNT");
         _balance[account] = _balance[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0),account,amount );
    }

    /// @notice burn, external burn function, will burn tokens from the owner's account
    ///@param account, the account from which tokens will be burned
    /// @param amount , the amount of tokens to be burned
    /// @return boolean, returns true if the operation succeeds
    function burn(address account, uint amount) external override onlyOwner returns (bool) {
        _burn(account, amount);
        return true;
    }

    /// @notice _burn, internal burn function, handles the events and checks before burning tokesn from owner's account
   ///@param account, the account from which tokens will be burned
   /// @param amount , the amount of tokens to be burned
    function _burn(address account, uint amount) internal virtual {
        require(_balance[account]>= amount, "INSUFFICIENT_BALANCE_TO_BURN");
        _balance[account] = _balance[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender,address(0),amount );

    }

    /// @notice transferFrom, sends the allowance amount alloted to msg.sender to a receiver
    /// @param src  source of the tokens
    /// @param dst  destination of the tokens
    /// @param amount the allowance amount
    /// @dev Checkes the msg.sender allowances before calling an internal transfer function for checks and effects
    function transferFrom(
        address src,
        address dst,
        uint amount
    ) external override returns (bool) {
        require(src!= address(0),"INVALID_SRC_ADDR");
        require(amount>0,"INVALID_TRANSFER_AMOUNT");
        require(amount <= _allowance[src][msg.sender],"INSUFFICIENT_ALLOWANCE");
        require(dst!= address(0) && dst != src,"INVALID_DEST_ADDR");
        _transfer(src,dst,amount);
        _approve(src, msg.sender, _allowance[src][msg.sender].sub(amount));
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
        console.log("transfer recipient:", recipient);
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
        require(recipient != address(0),"ADDRESSZERO_ERROR");
        _balance[sender]= _balance[sender].sub(amount);
        _balance[recipient]= _balance[recipient].add(amount);
        emit Transfer(sender,recipient,amount);
         }



    /// @notice approve, sets approval for the spender on behalf on msg.sender for amount
    /// @param spender  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev emits an approval event, prevent race condition checking initial approval =zero
    function approve(
        address spender,
        uint amount
    ) external override  returns (bool) {
        require(amount ==0 || _allowance[msg.sender][spender]==0,"Initial approval condition not met!");
        _approve(msg.sender, spender, amount);
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
        _allowance[account][spender] = amount;
        emit Approval(account,spender,amount);
    }


}