
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";
import "./IWETH.sol";



///@notice Wrap_UnWrapETH handles wrapping the unwrapping ETH to WETH for the caller
contract Wrap_UnWrapETH  {

address private WETH_ADDR;
IWETH weth;
address private _owner;
mapping (address => uint) public wethDepositBalance;
event UnWrappedWETH(uint amountWETH);
event WrappedETH(uint amountETH);
event Log(string func, uint gas);
event deposit_NotHeld(uint amount);
event deposit_holdWETH(uint amount);
constructor(address WETH_ADDR_) payable {
    WETH_ADDR = WETH_ADDR_;
    weth = IWETH(WETH_ADDR);
    _owner = msg.sender;
}

///@notice deposit function will Wrap ETH and transfer WETH back to the sender,
///@dev the contract doesn't hold the WETH funds. deposit_NotHeld(uint) event emitted
function  deposit() external payable {
    console.log("Depositing caller's ETH and transfer the WETH to the caller ...");
    uint amount = msg.value;
    weth.deposit{value: msg.value}();
    weth.transfer(msg.sender,amount);
    emit deposit_NotHeld(msg.value);
    // console.log("Owner's WETH balance:",IWETH(WETH_ADDR).balanceOf(msg.sender));
    
}

///@notice deposit_HoldWETH function will Wrap ETH and but hold the WETH funds in the contract
///@dev an internal mapping wethDepositBalance[msg.sender] is updated to 
///        track the sender's WETH balance to be withdrawn at a later stage
///         deposit_holdWETH(uint) event emitted
function  deposit_HoldWETH() external payable {
    console.log("Depositing caller's ETH to be held in the contract...");
    weth.deposit{value: msg.value}();
    wethDepositBalance[msg.sender] += msg.value;
    emit deposit_holdWETH(msg.value);
    // console.log("Deposit balance updated:", wethDepositBalance[msg.sender] );
    // console.log("Contract's WETH balance should be >0:",weth.balanceOf(address(this)));


}

    /// @notice withdraw all of the sender's WETH balance being held in the contract
    /// @dev Checks and effects pattern used, balances variables are updated
    ///      before doing a low level call to transfer the sender's ETH funds
    function withdraw() external payable {
        uint256 value = weth.balanceOf(address(this));
        uint256 senderBalance = wethDepositBalance[msg.sender];
         require(value>= senderBalance,"Contract has insufficient funds");
            weth.withdraw(senderBalance);
            safeTransferETH(payable(msg.sender),address(this).balance);

    }
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    ///@notice safeTransferETH internal function performs the low level call function
    function safeTransferETH(address payable to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }




    ///@notice checks if the msg.sender is the owner who deployed this contract
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }




    ///@notice getWETHAddr returns the WETH token address
    function getWETHAddr() external view returns (address) {
        return WETH_ADDR;
    }

    ///@notice getOwner returns the address that deployed the contract
    function getOwner() external view returns (address) {
        return _owner;
    }
    ///@notice getContractBalance , returns the balance of the contract
    ///@dev onlyOwner modifier ensures that only the deployer can make this query
    function getContractBalance() external view onlyOwner returns (uint) {
        return address(this).balance;
    }

        ///@notice getContractWETHBalance , returns the balance of the contract
    ///@dev onlyOwner modifier ensures that only the deployer can make this query
    function getContractWETHBalance() external view onlyOwner returns (uint) {
        return _wethBal(address(this));
    }


    ///@notice getWETHBalance , returns the WETH balance of the contract
    ///@param account, balance of account address is returned
    function getWETHBalance(address account) external view returns (uint) {
        return _wethBal(account);
    }


    ///@notice getETHBalance , returns the WETH balance of the contract
    ///@param account, balance of account address is returned
    function getETHBalance(address account) external view returns (uint) {
        return account.balance;
    }


  function _wethBal(address account) internal view returns (uint) {
    return weth.balanceOf(account);
  }
}
