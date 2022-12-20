// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;
// import "./UniSwap.sol";
import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "./IERC20.sol";
import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


 
contract SwapForDai {
    ISwapRouter public immutable swapRouter;
    using SafeMath for uint;
    // address  public immutable DAI;
    // address  public immutable WETH;
    address private _owner;
    IWETH private weth;
    IERC20 private dai;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    mapping (address => uint) private _depositBal;

    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint _amount);
    event Received(address _sender, uint _value);
    event Deposit(address account, uint value);
    event Withdraw(address account, uint value);

    event Refund(address _refunder, uint _value);
    event NoRefund();
    constructor(
            address  WETH_,
            address  DAI_,
            ISwapRouter _swapRouter)  payable {
        weth = IWETH(WETH_);
        dai = IERC20(DAI_);
        swapRouter = _swapRouter;
        _owner = msg.sender;
    }

  
  

  /// @notice WrapSomeETHAndSwap takes in the use's ETH and wraps to WETH before the swap operation to DAI
    /// @dev returns true
    ///
    function WrapSomeETHAndSwap(uint amountToUse) external payable returns (uint amountOut) {
        console.log("Amount Sent:", msg.value);
        console.log("Amount To use:", amountToUse);
        console.log("ETH being wrapped...", amountToUse);

        _refund(msg.sender, amountToUse, msg.value);

        weth.deposit{value: amountToUse }();
        weth.approve(address(this), amountToUse);
        uint amountInWETH = weth.balanceOf(msg.sender);

        weth.transferFrom(WETH,address(this),amountInWETH);
        amountInWETH = weth.balanceOf(address(this));
        console.log("Balance of address(this) after",amountInWETH);
      
        weth.approve(address(swapRouter), amountInWETH );
        uint getRouterAllowance = weth.allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);

        amountOut = _swap(amountInWETH);
        console.log("amountOut:", amountOut);
        emit SwapCompleted(amountOut);
    }
/// @notice WrapAllETHAndSwap takes in the use's ETH and wraps to WETH before the swap operation to DAI
    /// @dev returns true
    ///
    function WrapAllETHAndSwap() external payable returns (uint amountOut) {
        console.log("Input ETH Amount=", msg.value);
        weth.deposit{value: msg.value }();
        weth.approve(address(this), msg.value);
        uint amountInWETH = weth.balanceOf(msg.sender);

        weth.transferFrom(WETH,address(this),amountInWETH);
        amountInWETH = weth.balanceOf(address(this));
        console.log("Balance of address(this) after",amountInWETH);
      
        weth.approve(address(swapRouter), amountInWETH );
        uint getRouterAllowance = weth.allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);

        amountOut = _swap(amountInWETH);
        console.log("amountOut:", amountOut);
        emit SwapCompleted(amountOut);
    }

    /// @notice swapWETHforDai_EIS (EIS-ExactInputSingle) swaps amountIn tokens to exact amountOut
    /// using the DAI/WETH9 0.3% pool by calling the 
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @param _amountOut maximum possible output of WET or DAI received
    ///

    function _swap(uint amountIn) internal returns (uint _amountOut) 
    {
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : WETH,
                tokenOut : DAI,
                fee: 3000,
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




    /// @notice owner, returns the owner address or deployer address
    /// @return owner who deployed the SwapETH2DAI contract
    function owner() external view returns (address) {
        return _owner;
    }

    ///@notice checks if the msg.sender is the owner who deployed this contract
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }



    ///@notice _refund, internal function that handles the sending the excess ETH refund
    ///@param account, the account that'll receive the excess refund
    ///@dev emits either a Refund or NoRefund event
    function _refund(address payable account, uint amountToUse, uint amountSent) internal  {
        if (amountSent > amountToUse) {
            uint amountToRefund = (amountSent).sub(amountToUse);
            console.log("_refund Function: Refund Amount:",amountToRefund);
            _sendETH(account,amountToRefund);
            emit Refund(account,amountToRefund);
        } 

    }


    ///@notice _sendETH internal function to handle sending ETH, emits Refund event
    ///@param account: payable account that'll get the refund in ETH
    ///@param _value: amount of ETH to be refunded to the account
    function _sendETH(address payable account, uint _value) internal  {
        console.log("_sentEth function: Sending refund to \nAddr: %s \nETH Refund: %s", account, _value);
        (bool success, ) = payable(account).call{value: _value}("");
        require(success, "Refund didn't go through successfully");
    }

    }