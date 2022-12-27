// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;
import "hardhat/console.sol";
/// @title Deploy NOTEOA with swap contract address to call the Deposit Function
/// @author Sandip Nallani
/// @notice The deposit call from this contract should fail 
/// @dev only EOAs are allowed to call the depositALLETH/depositSomeETH functions in the SwapContract.sol

contract NOTEOA{
    address private _SwapContract;
    uint private ETH_Amount= 1 ether;
    uint private ETH_AmountToUse = 0.5 ether;
    address private _owner;
    constructor (address SwapContract) {
        _SwapContract = SwapContract;
        _owner = msg.sender;
    }

    modifier onlyOwner{
        require(_owner == msg.sender,"NOT_THE_OWNER");
        _;
    }
    function callDepositSwapSomeETH()  external onlyOwner {
        console.log("Swap Contract address from NOTEOA %s:", _SwapContract);
        (bool success, ) = _SwapContract.call{value: ETH_Amount}
                                    (abi.encodeWithSignature("SwapSomeETH_DAI(uint256)",ETH_AmountToUse));
        require(success,"NOT_ALLOWED_TO_PARTICIPATE_SwapSomeETH");
    }

    function callDepositSwapAllETH()  external onlyOwner {
        console.log("Swap Contract address from NOTEOA %s:", _SwapContract);
        (bool success,) = _SwapContract.call{value: ETH_Amount}
                                    (abi.encodeWithSignature("SwapAllETH_DAI()"));
        require(success,"NOT_ALLOWED_TO_PARTICIPATE_SwapAllETH");
    }

    fallback() external payable{//Do somethign malicious here
    }
    receive() external payable{}

}