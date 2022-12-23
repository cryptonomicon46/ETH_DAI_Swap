
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";



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

constructor(address WETH_ADDR_) {
    WETH_ADDR = WETH_ADDR_;
    weth = IWETH(WETH_ADDR);
    _owner = msg.sender;
}



    function withdraw(uint wad) external payable {
        weth.approve(address(this),wad);

        // weth.withdraw(wad);
     (bool success, ) = WETH_ADDR.call(abi.encodeWithSignature("withdraw(uint)",wad));
    require(success,"Withdraw{Signature} failed!");
        console.log("Contract's WETH balance:",weth.balanceOf(msg.sender));

        console.log("Sender's WETH balance after withdraw:",weth.balanceOf(msg.sender));

    }


function _depositSignature() internal  {
    (bool success, ) = WETH_ADDR.call{value: msg.value}(abi.encodeWithSignature("deposit()"));
    require(success,"Deposit failed!");
    console.log("Contract's WETH balance", weth.balanceOf(address(this)));
    weth.transferFrom(address(this),msg.sender, weth.balanceOf(address(this)));
    console.log("Sender's balance after transferFrom:", weth.balanceOf(msg.sender));




function _withdraw_Signature(uint wad) internal {
    weth.approve(address(this),wad);
     (bool success, ) = WETH_ADDR.delegatecall(abi.encodeWithSignature("withdraw(uint)",wad));
    require(success,"Withdraw{Signature} failed!");

}


function _withdraw_Selector(uint wad) internal {
     (bool success, ) = WETH_ADDR.delegatecall(abi.encodeWithSelector(IWETH.withdraw.selector,wad));
    require(success,"Withdraw{Selector} failed!");

}



///@notice Wrap_ETH will wrap msg.value in ETH using an internal function _depositSignature()
///@dev internal function _depositSignature does a low level function call on the WETH9 contract, emits WrappedETH event
function Wrap_ETH() external payable returns (bool) {
    _depositSignature();
    emit WrappedETH(msg.value);
    return true;
}

///@notice UnWrap_WETH_Signature unwraps WETH to native ETH 
///@notice amountWETH is withdrawn from the WETH9 contract via low level function call
///@dev internal function _withdraw_Signature does a low level function call on the WETH9 contract to withdraw, emits UnWrappedWETH event
function UnWrap_WETH_Signature(uint amountWETH) external returns (bool) {
    _withdraw_Signature(amountWETH);
    emit UnWrappedWETH(amountWETH);
    return true;

}

///@notice UnWrap_WETH_Selector unwraps WETH to native ETH by withdrawing funds
///@notice amountWETH is the input WETH amount to withdraw from the WETH9 contract
///@dev internal function _withdraw_Selector does a low level function call on the WETH9 contract, emits UnWrappedWETH event 
function UnWrap_WETH_Selector(uint amountWETH) external returns (bool) {
    _withdraw_Selector(amountWETH);
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
