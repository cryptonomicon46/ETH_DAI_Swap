
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "hardhat/console.sol";
import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract SwapETH2DAI {
    ISwapRouter public immutable swapRouter;

    mapping (address => uint) private ETHBalanceOf;
    mapping(address => uint) private DAIBalanceOf;
    event TXIN_ETH(address sender, uint amount);
    address public immutable DAI;
    address public immutable ETH;
    uint24 public constant poolFee = 3000;
    event SwapETHForDai(uint amountInETH,uint amountOutDAI);
    event WithDrawETH(uint ethAmount);
    event WithDrawDAI(uint daiAmonut);
    constructor(address DAI_,
            address ETH_,
              ISwapRouter _swapRouter) payable {

        DAI = DAI_;
        ETH = ETH_;       
        swapRouter = _swapRouter;
    }
    bool internal locked;
    modifier noReentrance() {
        require(!locked,"REENTRANCE");
        locked = true;
        _;
        locked = false;
    }

    /// @notice swapETHforDai (ExactInputSingleHop) swaps amountInETH 
    ///tokens to exact amountOutDAI
    /// amountInETH should be less than owener's ETH Balance
    /// owner's ETH balance should be greater than 0.1 ether
    /// @param amountInETH input ETH amount to swap to DAI
    function swapETHForDai(uint amountInETH) external payable returns (uint amountOutDAI) 
    {   
       
        require(amountInETH <= ETHBalanceOf[msg.sender] && ETHBalanceOf[msg.sender]> 0.1 ether, "INVALID_SWAP_OPERATION");
        ETHBalanceOf[msg.sender] -= amountInETH;
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : ETH,
                tokenOut : DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountInETH,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
           
        amountOutDAI = ISwapRouter(swapRouter).exactInputSingle(params);
        emit SwapETHForDai(amountInETH, amountOutDAI);

        DAIBalanceOf[msg.sender] += amountOutDAI;        
    }


    function withdrawETH() external payable noReentrance() {
        require(ETHBalanceOf[msg.sender]>0, "ETH_BALANCE_ZERO");     
        (bool success, ) = payable(msg.sender).call{value: ETHBalanceOf[msg.sender]}("");
        require(success);
        emit WithDrawETH(ETHBalanceOf[msg.sender]);
        ETHBalanceOf[msg.sender] = 0;

    }
    
    /// @notice withdraw DAI balance belonging to msg.sender if > 0 
   function withdrawDAI() external payable noReentrance() {
        require(DAIBalanceOf[msg.sender]>0, "DAI_BALANCE_ZERO");
        (bool success, ) = payable(msg.sender).call{value: DAIBalanceOf[msg.sender]}("");
        require(success);
        emit WithDrawDAI(DAIBalanceOf[msg.sender]);
        DAIBalanceOf[msg.sender] = 0;


    }

    /// @notice get owner's ETH balance
   function getETHBalance() external view returns (uint eth_amount) {
        eth_amount = ETHBalanceOf[msg.sender];
    }

    /// @notice get owner's DAI balance
   function getDAIBalance() external view returns (uint dai_amonut) {
        dai_amonut = DAIBalanceOf[msg.sender];
    }

    /// @notice receive function has to be delacred to receive ETH from a sender
    /// @dev requires input value to be greater than 0.1ETH
    /// emits TXIN_ETH(msg.sender, msg.value) upon sucess 
    ///
    receive() external payable {
        require(msg.value > 0.1 ether,"INVALID_INPUT_ETH_VALUE");
        ETHBalanceOf[msg.sender] += msg.value;
        emit TXIN_ETH(msg.sender,msg.value);
    }


    
    }