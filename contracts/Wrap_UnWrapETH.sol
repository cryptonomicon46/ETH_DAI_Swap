
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

// import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;

    function balanceOf(address account) external view returns (uint256);

}

///@notice Wrap_UnWrapETH handles wrapping the unwrapping ETH to WETH for the caller
contract Wrap_UnWrapETH  {

address private WETH_ADDR;
IWETH weth;
address private _owner;
event UnWrappedWETH(uint amountWETH);
event WrappedETH(uint amountETH);
constructor(address WETH_ADDR_) {
    WETH_ADDR = WETH_ADDR_;
    weth = IWETH(WETH_ADDR);
    _owner = msg.sender;
}


function _depositSignature() internal  {
    (bool success, ) = WETH_ADDR.call{value: msg.value}(abi.encodeWithSignature("deposit()"));
    require(success,"Deposit failed!");
}

function _depositSelector() internal  {
    (bool success, ) = WETH_ADDR.call{value: msg.value}(
        abi.encodeWithSelector(IWETH.deposit.selector));
    require(success,"Deposit{Selector} failed!");
}


function _withdraw_Signature(uint wad) internal {
     (bool success, ) = WETH_ADDR.call(abi.encodeWithSignature("withdraw(uint)",wad));
    require(success,"Withdraw{Signature} failed!");

}


function _withdraw_Selector(uint wad) internal {
     (bool success, ) = WETH_ADDR.call(abi.encodeWithSelector(IWETH.withdraw.selector,wad));
    require(success,"Withdraw{Selector} failed!");

}
///@notice Wrap_ETH_Selector will wrap msg.value in ETH 
///@dev internal function _depositSelector does a low level function call on the WETH9 contract, emits WrappedETH event
function Wrap_ETH_Selector() external payable returns (bool) {
    _depositSelector();
    emit WrappedETH(msg.value);
    return true;

}


///@notice Wrap_ETH_Signature will wrap msg.value in ETH using an internal function _depositSignature()
///@dev internal function _depositSignature does a low level function call on the WETH9 contract, emits WrappedETH event
function Wrap_ETH_Signature() external payable returns (bool) {
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
