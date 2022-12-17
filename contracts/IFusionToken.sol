// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;


interface IFusionToken {


    /// @dev Transfer event triggered when 'amount' is transferred to 'recipient' along with ETH 'value' sent
    /// 'value' can be left as 0  
    /// Emitted from mint, burn, transferFrom, transfer, transferFrom_Wei, transfer_Wei functions
    event Transfer(address recipient, uint amount, uint value);

    /// @dev Approval event triggered when allowance for 'spender' on behalf of 'owner' is updated to 'amount' 
    /// emitted from allowance, approve functions
    event Approval(address owner, address spender, uint amount);



    /// @notice totalSupply returns the total supply of the minted Fusion Token
    function totalSupply() external view returns (uint);
    

   /// @notice decimal the decimal value for the token, by default set to 18 to mimic ETH to WEI conversion
    ///
    function decimal() external view returns (uint);


    /// @notice balanceOf returns the balance of the account in unit
    /// @param owner , the account balance to return
    function balanceOf(address owner) external view returns (uint);


    /// @notice allowance, sets the allowance for spender on behalf of owner, emits Approval event
    /// @param owner ,  account owner
    /// @param spender , account that plans to spend on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint);

 
    /// @notice mint, will mint tokens for the account and updates balances, emits Transfer event
    /// @param account, account that'll receive the minted tokens
    /// @param amount , minted amount
    function mint(address account, uint amount) external;

    /// @notice burn, will burn tokens from the account, updates balances and emits Transfer event
    /// @param account that'll lose the tokens on burn
    /// @param amount , the amount of tokens to be burned
    function burn(address account, uint amount) external;


    /// @notice transferFrom, will transfer amount from owner to recipient, tigger the Transfer event, return bool  (pass/fail)
    /// @param owner , account from which tokens are sent
    /// @param recipient , receiver of the tokens
    /// @param amount , amount received by the recipient 
    function transferFrom(address owner, address recipient, uint amount) external view returns (bool);
   
    /// @notice transfer, will transfer amount to recipient, tigger the Transfer event, return bool  (pass/fail)
    /// @param recipient, receives tokens
    /// @param amount , amount of tokens transferred
    function transfer(address recipient, uint amount) external view returns (bool);


    /// @notice transferFrom_Wei, will transfer amount from owner to recipient, tigger the Transfer event, return bool  (pass/fail)
      /// will also transfer value as msg.value
   /// @param owner , account from which tokens are sent
    /// @param recipient , recipient of the transfer
    /// @param amount , amount of tokens transferred
    /// @param value  msg.value sent along with the transfer
    function transferFrom_Wei(address owner, address recipient, uint amount, uint value) external view returns (bool);
   
    /// @notice transfer_Wei, will transfer amount to recipient, tigger the Transfer event, return bool  (pass/fail)
   /// will also transfer value as msg.value
    /// @param recipient, receiver of the tokens
    /// @param amount , amount of tokens transferred
    /// @param value  msg.value sent along with the transfer

    function transfer_Wei(address recipient, uint amount, uint value) external view returns (bool);


    /// @notice approve, will approve the spender for an allowance of amount, emits Approval event, returns boolean
    /// @param spender , spender of the approved funds
    /// @param amount , amount set as allowance or approved to spend from the msg.sender
    function approve(address spender, uint amount) external view returns (bool);

}