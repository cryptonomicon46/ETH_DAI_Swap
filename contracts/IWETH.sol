// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;


/// @title IWETH contract interface that has all the ERC20 capabilities
/// @author Sandip Nallani
/// @notice This will be inherited by the WETH contract and then by the DepositAndWithdraw.sol contract to wrap/UnWrap user's ETH
interface IWETH {


    /// @dev Transfer event triggered when 'amount' is transferred to 'recipient' along with ETH 'value' sent
    /// 'value' can be left as 0  
    /// Emitted from mint, burn, transferFrom, transfer, transferFrom_Wei, transfer_Wei functions
    event Transfer(address indexed owner, address indexed recipient, uint amount);

    /// @dev Approval event triggered when allowance for 'spender' on behalf of 'owner' is updated to 'amount' 
    /// emitted from allowance, approve functions
    event Approval(address indexed owner, address indexed spender, uint amount);

    // receive() external payable;



    ///@dev Despoit event raised when an account deposits ETH into the contract
    ///@param src: sender of the deposit
    ///@param wad: ETH value deposited 
    event Deposit(address src, uint wad);


    ///@dev Despoit event raised when an account deposits ETH into the contract
    ///@param src: sender of the deposit
    ///@param wad: ETH value deposited 
    event Withdraw(address indexed src, uint wad);
    /// @notice totalSupply returns the total supply of the minted Fusion Token
    function totalSupply() external view returns (uint);

    /// @notice name returns the name of the token
    function name() external view returns (string memory);
    

    /// @notice symbol returns the symbool of the token
    function symbol() external view returns (string memory);

   /// @notice decimal the decimal value for the token, by default set to 18 to mimic ETH to WEI conversion
    ///
    function decimal() external view returns (uint);


    /// @notice balanceOf returns the balance of the account in unit
    /// @param owner , the account balance to return
    function balanceOf(address owner) external view returns (uint256);


    /// @notice allowance, sets the allowance for spender on behalf of owner, emits Approval event
    /// @param owner , owner account for the allowance
    /// @param spender , account that plans to spend on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint);

 

    /// @notice transferFrom, will transfer amount from owner to recipient, tigger the Transfer event, return bool  (pass/fail)
    /// @param owner , receiver of the tokens
    /// @param recipient , receiver of the tokens
    /// @param amount , amount received by the recipient 
    function transferFrom(address owner, address recipient, uint amount) external  returns (bool);
   
    /// @notice transfer, will transfer amount to recipient, tigger the Transfer event, return bool  (pass/fail)
    /// @param recipient, receiver of the tokens
    /// @param amount , amount of tokens transferred
    function transfer(address recipient, uint amount) external  returns (bool);


   /// @notice approve, will approve the spender for an allowance of amount, emits Approval event, returns boolean
    /// @param spender , spender of the approved funds
    /// @param amount , amount set as allowance or approved to spend from the msg.sender
    function approve(address spender, uint amount) external returns (bool);


   /// @notice deposit, to deposit native ETH into the contract
   ///@dev emits a deposit event
    function deposit() external payable;

   /// @notice withdraw, to withdraw the original ETH from the wrapped contract
   ///@dev emits a withdraw event
    function withdraw(uint256 wad) external;


}