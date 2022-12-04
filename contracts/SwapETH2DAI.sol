
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;
// import "./UniSwap.sol";
import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

 
interface IWETH is IERC20 {

/// @notice deposit WETH9 from the sender
function deposit() external payable;

/// @notice withdraw WETH9 
function withdraw(uint) external payable;

}
contract SwapETH2DAI {
    ISwapRouter public immutable swapRouter;

    address public immutable DAI;
    address public immutable WETH9;
    uint24 constant poolFee = 3000;

    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint _amount);
    event Received(address _sender, uint _value);
    constructor(address DAI_, 
            address WETH9_,
              ISwapRouter _swapRouter) {

        DAI = DAI_;
        WETH9 = WETH9_; 
        swapRouter = _swapRouter;

    }


    /// @notice SwapETHToDai takes in the use's ETH and wraps to WETH before the swap operation to DAI
    /// @dev returns true
    ///
    function SwapETHToDai() external payable returns (uint amountOut) {
        require(msg.value > 0.1 ether, "ETH_VALUE_TOO_LOW");
        console.log("Input ETH Amount=", msg.value);
        IWETH(WETH9).deposit{value: msg.value }();

        IERC20(WETH9).approve(address(this), msg.value);
        uint amountInWETH = IERC20(WETH9).balanceOf(msg.sender);

        IERC20(WETH9).transferFrom(WETH9,address(this),amountInWETH);
        amountInWETH = IERC20(WETH9).balanceOf(address(this));
        console.log("Balance of address(this) after",amountInWETH);
      
        IERC20(WETH9).approve(address(swapRouter), amountInWETH );
        uint getRouterAllowance = IERC20(WETH9).allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);

        amountOut = _swapWETHForDai(amountInWETH);
        console.log("amountOut:", amountOut);
        emit SwapCompleted(amountOut);
    }

    /// @notice swapWETHforDai_EIS (EIS-ExactInputSingle) swaps amountIn tokens to exact amountOut
    /// using the DAI/WETH9 0.3% pool by calling the 
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @param _amountOut maximum possible output of WET or DAI received
    ///
    function _swapWETHForDai(uint amountIn) internal returns (uint _amountOut) 
    {
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : WETH9,
                tokenOut : DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            //Executes the swap
        _amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        console.log("amountOut=", _amountOut);     
    }

   /// @notice for empty calldata
    receive() external payable {}

    /// @notice when no other function matches, not even receive
    fallback() external payable{}
    }