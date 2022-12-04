
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;
// import "./UniSwap.sol";
import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

 
interface IWETH is IERC20 {

/// @notice deposit WETH9 from the sender
function deposit() external payable;

/// @notice withdraw WETH9 
function withdraw(uint) external payable;

}
contract SwapETH2DAI {
    ISwapRouter public immutable swapRouter;
    IWETH public immutable weth;
    IERC20 public immutable dai;
    uint24 constant poolFee = 3000;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant ETH = 0x73bFE136fEba2c73F441605752b2B8CAAB6843Ec;
    address constant SwapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint amountInETH,uint amountOutDAI);
    event Received(address _sender, uint _value);
    constructor() payable {

        swapRouter = ISwapRouter(SwapRouterAddress);
        weth = IWETH(WETH);
        dai = IERC20(DAI);
        }

    /// @notice swapETHforDai 
    ///Owner transfers ETH as msg.value, the function wraps the needed ETH ->WETH9 
    /// completes the swap operation and updates the owener's DAI balance
    /// @dev emits event SWAP_COMPLETE(uint amountInETH,uint amountOutDAI) 
    /// upon successful completion of the swap of ETH to DAI. 
      function swapETHForDai() external payable {
        require(msg.value > 0.1 ether, "ETH_VALUE_TOO_LOW");
        require(msg.sender != address(0),"INVALID_SENDER_ADDRRESS");

        weth.deposit{value:msg.value }();
        uint amountInWETH = IERC20(WETH).balanceOf(msg.sender);
        IERC20(WETH).transferFrom(WETH,address(this),amountInWETH);
        console.log("Balance of address(this)",IERC20(WETH).balanceOf(address(this)));
        weth.approve(address(swapRouter), msg.value);
        uint getRouterAllowance = IERC20(WETH).allowance(address(this),address(swapRouter));
        console.log("Print Router's allowance",getRouterAllowance);

           ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : WETH,
                tokenOut : DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountInWETH,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
           
        uint amountOutDAI = ISwapRouter(swapRouter).exactInputSingle(params);
        console.log("Swap completed and DAI received =", amountOutDAI);
        // emit SwapCompleted(msg.value, amountOutDAI);
        // console.log("DAI tokens received", amountOutDAI);
        // // // //Transfer owner's DAI balances
        // console.log("Sender's DAI bal after wrap:", IERC20(DAI).balanceOf(msg.sender));    
    }

   /// @notice for empty calldata
    receive() external payable {}

    /// @notice when no other function matches, not even receive
    fallback() external payable{}
    }