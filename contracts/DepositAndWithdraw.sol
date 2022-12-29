
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";
import "./IWETH.sol";



///@notice DepositAndWithdraw handles wrapping the unwrapping ETH to WETH for the caller
contract DepositAndWithdraw  {
using SafeMath for uint;
address private WETH_ADDR;
IWETH weth;
address private _owner;
mapping (address => uint) public wethDepositBalance;

event Log(string func, uint gas);
event deposit(uint amount);
event withdraw(uint wad);
// event deposit_holdWETH(uint amount);
constructor(address WETH_ADDR_) payable {
    WETH_ADDR = WETH_ADDR_;
    weth = IWETH(WETH_ADDR);
    _owner = msg.sender;
}

///@notice Wrap_ETH function will Wrap user's ETH and transfer WETH back to the sender,
///@dev the contract doesn't hold the WETH funds. deposit_NotHeld(uint) event emitted
function  Wrap_ETH() external payable {
    console.log("Depositing caller's ETH and transfer the WETH to the caller ...");
    uint amount = msg.value;
    weth.deposit{value: msg.value}();
    weth.transfer(msg.sender,amount);
    emit deposit(msg.value);
    
    console.log("Owner's WETH balance:",weth.balanceOf(msg.sender));
    console.log("Contract's WETH balance:",weth.balanceOf(address(this)));

    
}


    /// @notice UnWrap_WETH will convert the sender's WETH balance to ETH and transfer it back to the sender
    /// @dev Checks and effects pattern used, balances variables are updated
    ///      before doing a low level call to transfer the sender's ETH funds


    /// @notice UnWrap_WETH will convert some of the sender's WETH balance to ETH and transfer it back to the sender
   /// @param wad amount of WETH user balance converted back to ETH
    /// @dev Checks and effects pattern used, WETH balance variable is updated
    ///      before doing a low level call to transfer WETH to the user
    ///      emits a withdraw event 
    function UnWrap_WETH(uint wad) external {
        console.log("User wishes the contrac to unwrap %s WETH", wad);
        console.log("User sets contract allowance at %s WETH", weth.allowance(msg.sender, address(this)));

        require(weth.balanceOf(msg.sender)>= wad, "INSUFFICIENT_USER_WETH_FUNDS!");
            weth.transferFrom(msg.sender, address(this),wad);
            console.log("Contract's WETH balance:", weth.balanceOf(address(this)));
            weth.withdraw(wad);
            console.log("Contract's ETH balance:",address(this).balance);

            // wethDepositBalance[msg.sender] = wethDepositBalance[msg.sender].sub(wad);
            safeTransferETH(payable(msg.sender),wad);
            emit withdraw(wad);
    }
    // // Function to receive Ether. msg.data must be empty
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


        ///@notice getContractETHBalance , returns the ETH balance of the contract
    ///@dev onlyOwner modifier ensures that only the deployer can make this query
    function getContractETHBalance() external view onlyOwner returns (uint) {
        return (address(this).balance);
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
