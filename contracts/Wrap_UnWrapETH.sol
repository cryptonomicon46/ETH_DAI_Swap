
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";
import "./IERC20.sol";


// interface IWETH is IERC20 {
//     function deposit() external payable;

//     function withdraw(uint amount) external;
// }

///@notice Wrap_UnWrapETH handles wrapping the unwrapping ETH to WETH for the caller
contract Wrap_UnWrapETH  {

address private WETH_ADDR;
IWETH weth;
address private _owner;
event UnWrappedWETH(uint amountWETH);
event WrappedETH(uint amountETH);
event Log(string func, uint gas);

constructor(address WETH_ADDR_) payable {
    WETH_ADDR = WETH_ADDR_;
    weth = IWETH(WETH_ADDR);
    _owner = msg.sender;
}



function _deposit() internal  {
    (bool success, ) = WETH_ADDR.call{value: msg.value}(abi.encodeWithSignature("deposit()"));
    require(success,"Deposit failed!");
    console.log("Contract's WETH balance", weth.balanceOf(address(this)));
    weth.transferFrom(address(this),msg.sender, weth.balanceOf(address(this)));
    console.log("Sender's balance after transferFrom:", weth.balanceOf(msg.sender));

}


function _withdraw(uint wad) public {
     console.log("Withdraw input:",wad);

    console.log("Senders's WETH balance to withdraw:",weth.balanceOf(msg.sender));
    console.log("Approving this contract for funds...", wad, msg.sender);
    // (bool success1, ) = WETH_ADDR.delegatecall(abi.encodeWithSignature("approve(address,uint)",address(this),wad));
    // require(success1,"Approve{delegatecall} failed!");
    weth.approve(address(this),wad);
    console.log("Transferring WETH balance of %s from sender to this contract...", wad);

    // (bool success2, ) = WETH_ADDR.delegatecall(abi.encodeWithSignature("transfer(address,uint)",address(this),wad));
    // require(success2," transferFrom{delegatecall} failed!");
    // weth.transferFrom(msg.sender,address(this),wad);
    address(this).transfer(wad);

    console.log("Contract's WETH balance after the transfer:",weth.balanceOf(address(this)));




     (bool success3, ) = WETH_ADDR.delegatecall(abi.encodeWithSignature("withdraw(uint)",wad));
    require(success3,"Withdraw{delegatecall} failed!");

    console.log("Sender's WETH balance should be zero:",weth.balanceOf(msg.sender));

}


///@notice Wrap_ETH will wrap msg.value in ETH using an internal function _depositSignature()
///@dev internal function _depositSignature does a low level function call on the WETH9 contract, emits WrappedETH event
function Wrap_ETH() external payable returns (bool) {
    _deposit();
    emit WrappedETH(msg.value);
    return true;
}

///@notice UnWrap_WETH unwraps WETH to native ETH 
///@notice amountWETH is withdrawn from the WETH9 contract via low level function call
///@dev internal function _withdraw does a low level function call on the WETH9 contract to withdraw, emits UnWrappedWETH event
function UnWrap_WETH(uint amountWETH) external returns (bool) {
    _withdraw(amountWETH);
    emit UnWrappedWETH(amountWETH);
    return true;

}



    ///@notice getWETHAddr returns the WETH token address
    function getWETHAddr() external view returns (address) {
        return WETH_ADDR;
    }

function getOwner() external view returns (address) {
    return _owner;
}

 function getContractBalance() external view returns (uint) {
    return address(this).balance;
 }


}
