
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

/// @title WETH contract with all it's functions
/// @author Sandip Nallani
/// @notice This is the full ERC20 version of the WETH contract
/// @dev User deposits ETH to hold a WETH balance, withdraws WETH to get back ETH 
contract WETH is IWETH {

    using SafeMath for uint;
    string private _name= "Wrapped Ether Test";
    string private _symbol = "WETH-Test";
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
   
  

    /// @notice transferFrom, sends the allowance amount alloted to msg.sender on behalf of owner to the recipeient, emits Transfer event. 
    /// @param src  sender of the wad
    /// @param dst  receiver of the wad 
    /// @param wad the allowance amount
    /// @dev calls the internal _transfer function , adjusts the allowance, emits Transfer and Approval events.
    function transferFrom(
        address src,
        address dst,
        uint wad
    ) external override returns (bool) {
        require(src != address(0),"INVALID_SRC_ADDR");
        require(wad>0, "INVALID_TRANSFER_AMOUNT");
        require(src!= address(0),"INVALID_SRC_ADDR");

        require(wad <= _allowance[src][msg.sender],"INSUFFICIENT_ALLOWANCE!");
        require(dst!= address(0) && dst != src, "INVALID_DST_ADDR");
        _transfer(src,dst,wad);
        _approve(src, msg.sender, _allowance[src][msg.sender].sub(wad));
        return true;
    }

    /// @notice transfer, sends amount wad to dst, emits Transfer event. 
    /// @param dst  destination of the funds
    /// @param wad the allowance amount
    /// @dev checks balances of sender >= amount, checks of recipent != zero address
    function transfer(
        address dst,
        uint wad
    ) external  override returns (bool) {
        _transfer(msg.sender,dst,wad);
        return true;
    }


    /// @notice _transfer, internal function that handles sending amount to recipient, emits Transfer event. 
    /// @param src  sender of the funds
    /// @param dst  destination addres of the funds
    /// @param wad the allowance amount
    /// @dev checks balances of sender >= amount, checks of recipent != zero address, adjusts the balances and emits the Transfer event
    function _transfer(
        address src,
        address dst,
        uint wad
    ) internal {
        require(_balance[src] >= wad,"INSUFFICIENT_FOR_TRANSFER");
        require(dst != address(0),"INVALID_RECIPIENT");
        _balance[src]= _balance[src].sub(wad);
        _balance[dst]= _balance[dst].add(wad);
        emit Transfer(src,dst,wad);
         }



    /// @notice approve, sets approval for the spender on behalf on msg.sender for amount
    /// @param spender  spender seeking an allowance on behalf on msg.sender
    /// @param amount the allowance amount
    /// @dev emits an approval event
    /// @dev avoid race condition by only setting allowance if initial conditions are met

    function approve(
        address spender,
        uint amount
    ) external override returns (bool) {
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

    /// @notice deposit, payable function that receives the senders native ETH to wrap into WETH
    ///@dev emits a deposit event afte updating the user's balance
    function deposit() public payable override{
        console.log("Depositing Funds...");
           _balance[msg.sender] = _balance[msg.sender].add(msg.value);
        emit Deposit(msg.sender, msg.value);
    }
    


    /// @notice withdraw, allowas user to withdraw funds
    ///@dev emits a withdraw event, performs checks and effects to avoid reentrancy attacks
    function withdraw(uint wad) public override {
        require(_balance[msg.sender] >= wad,"NOTHING_TO_WITHDRAW");
        uint bal =  _balance[msg.sender];
        _balance[msg.sender] =  _balance[msg.sender].sub(wad);
        _sendETH(payable(msg.sender),bal);
        // msg.sender.transfer(wad);
        emit Withdraw(msg.sender, wad);
    }


    ///@notice _sendETH internal function to handle sending ETH, emits Refund event
    ///@param account: payable account that'll get the refund in ETH
    ///@param amount: amount of ETH to be refunded to the account
    function _sendETH(address payable account, uint amount) internal  {
        (bool success, ) = payable(account).call{value: amount}("");
        require(success, "FAILED_TO_SEND_FUNDS");
    }

    // ///@notice receive external payable, calls the internal _deposit function
    // receive() external override payable{
    //     _deposit();
    // }

}