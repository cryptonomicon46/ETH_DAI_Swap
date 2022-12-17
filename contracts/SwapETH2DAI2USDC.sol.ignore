
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
contract SwapETH2DAI2USDC {
    ISwapRouter public immutable swapRouter;

    address public immutable DAI;
    address public immutable WETH9;
    address public immutable USDC;
    uint24 constant poolFee = 3000;

    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint _amount);
    event Received(address _sender, uint _value);
    constructor(address DAI_, 
            address WETH9_,
            address USDC_,
              ISwapRouter _swapRouter) {

        DAI = DAI_;
        WETH9 = WETH9_; 
        USDC = USDC_;
        swapRouter = _swapRouter;

    }


    /// @notice SwapETHToDai takes in the use's ETH and wraps to WETH before the swap operation to DAI
    /// @dev returns true
    ///
    function SwapETHToDaiToUSDC() external payable returns (uint amountOut) {
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

        amountOut = _swapWETHForDai_USDC(amountInWETH);
        // console.log("amountOut:", amountOut);
        console.log("msg.sender's DAI balance", IERC20(DAI).balanceOf(msg.sender));
        console.log("msg.sender's WETH9 balance", IWETH(WETH9).balanceOf(msg.sender)); 
        console.log("msg.sender's USDC balance", IERC20(USDC).balanceOf(msg.sender));
        emit SwapCompleted(amountOut);
    }

    /// @notice _swapWETHForDai_USDC 
    /// Exact input multi hop swaps will swap a fixed amount on a given input 
    /// token for the maximum amount possible for a given output, and can include an a
    /// rbitrary number of intermediary swaps.(EIS-ExactInputSingle) swaps amountIn 
    /// tokens to exact amountOut
    /// using the  0.3% pool by calling the 
    /// @param amountIn  The amount of ETH > 0.1 ether to be swapped
    /// @param _amountOut the amount of USDC received after the multihop swap
    function _swapWETHForDai_USDC(uint amountIn) internal returns (uint _amountOut) 
    {
            ISwapRouter.ExactInputParams memory params = 
                ISwapRouter.ExactInputParams({
                    path : abi.encodePacked(WETH9, poolFee, DAI, poolFee, USDC, poolFee),
                    recipient : msg.sender,
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: 0
                });

            //Executes the swap
        _amountOut = ISwapRouter(swapRouter).exactInput(params);
        console.log("amountOut=", _amountOut);     
    }

   /// @notice for empty calldata
    receive() external payable {}

    /// @notice when no other function matches, not even receive
    fallback() external payable{}
    }