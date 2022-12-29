// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;



import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "./IERC20.sol";
import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @title Swaps ETH to DAI by first wrapping it into WETH
/// @author Sandip Nallani
/// @notice Uses Uniswap's V3 router contract to perform the swap
/// @dev Contract holds the WETH after depositing caller's ETH. 

contract SwapContract {
    ISwapRouter public immutable swapRouter;
    using SafeMath for uint;
    using Address for address;

    address private _owner;
    IWETH private weth;
    IERC20 private dai;
    address private WETH_ADDR;
    address private DAI_ADDR;
    bool private _stopped;
    event SwapCompleted(uint _amount);
    event Refund(address _refunder, uint _value);
    event WETHAddr_Changed(address _weth);
    event ToggleStartStop(bool);
    constructor(
            address  WETH_,
            address  DAI_,
            ISwapRouter _swapRouter)  payable {
        WETH_ADDR = WETH_;
        DAI_ADDR = DAI_;
        weth = IWETH(WETH_ADDR);
        dai = IERC20(DAI_ADDR);
        swapRouter = _swapRouter;
        _owner = msg.sender;
    }

  



  /// @notice SwapSomeETH_DAI takes in the user's ETH but only uses some ETH to wrap and swap to DAI 
    /// @dev The user gets a refund of the ETH amount not used to Wrap or swap. 
    ///  emits a SwapCompleted event
    ///
    function SwapSomeETH_DAI(uint amountToUse) external payable StopDeposits returns (uint amountOut) {
        address account = msg.sender;
        require(!account.isContract(),"ONLY_EOAs_ALLOWED");
        console.log("Amount Sent:", msg.value);
        console.log("Amount To use:", amountToUse);
        console.log("WETH Supply:", WETH_ADDR.balance);
        console.log("DAI Supply:", DAI_ADDR.balance);

        _refund(msg.sender, amountToUse, msg.value);
        _deposit(amountToUse);
        console.log("WETH Balance of this contract", address(this).balance);
        // uint amountInWETH = _wethBal(address(this));
        // console.log("Balance of address(this) after",amountInWETH);  
        // uint amountInWETH = _wethBal(address(this));
        weth.approve(address(swapRouter), amountToUse );
        uint getRouterAllowance = weth.allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);
        amountOut = _swap(WETH_ADDR, DAI_ADDR,3000, amountToUse);
        console.log("DAI balace to be withdrawn later:", dai.balanceOf(msg.sender));
        emit SwapCompleted(amountOut);
    }


/// @notice SwapAllETH_DAI takes in the user's ETH and wraps to WETH before the swap operation to DAI
    /// @dev uses all the mag.value provided to wrap to WETH and then swap to DAI
    /// emits a SwapCompleted event
    function SwapAllETH_DAI() external payable StopDeposits returns (uint amountOut) {
        address account = msg.sender;
        require(!account.isContract(),"ONLY_EOAs_ALLOWED");
        console.log("Amount Sent:", msg.value);
        console.log("WETH Supply:", WETH_ADDR.balance);
        console.log("DAI Supply:", DAI_ADDR.balance);

        _deposit(msg.value);
    
        // uint amountInWETH = weth.balanceOf(address(this));
        // uint amountInWETH = _wethBal(address(this));
        uint amountInWETH = msg.value;

        console.log("Balance of address(this) after",amountInWETH);      
        weth.approve(address(swapRouter), amountInWETH );
        uint getRouterAllowance = weth.allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);
        amountOut = _swap(WETH_ADDR, DAI_ADDR,3000, amountInWETH);
        console.log("amountOut:", amountOut);
        emit SwapCompleted(amountOut);
    }


    /// @notice _swap internal function that  swaps amountIn tokens to exact amountOut
    /// using the DAI/WETH9 0.3% pool by calling the 
    /// @param tokenIn  Input token address to swap
    /// @param tokenOut  Output token address to swap
    /// @param poolFee  pool swap fees
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @return _amountOut maximum possible output of WET or DAI received
    function _swap(address tokenIn,
                address tokenOut, 
                uint24 poolFee,
                uint256 amountIn) 
                internal returns 
            (uint _amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : tokenIn,
                tokenOut : tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            //Executes the swap
        _amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        // console.log("amountOut=", _amountOut);     
    }




    /// @notice owner, returns the owner address or deployer address
    /// @return owner who deployed the SwapETH2DAI contract
    function owner() external view returns (address) {
        return _owner;
    }

    ///@notice checks if the msg.sender is the owner who deployed this contract
    modifier onlyOwner() {
        require(_owner == msg.sender, "NOT_THE_OWNER");
        _;
    }



    ///@notice if _stopped = false, then deposits are enabled, else disabled
    modifier StopDeposits {
        require(!_stopped,"DEPOSITS_DISABLED");
        _;
    }


    


    ///@notice ToggleContract, toggle stopped flag to stop deposits and only enable withdraws
    function ToggleContract() onlyOwner public{
        _stopped = !_stopped;
        emit ToggleStartStop(_stopped);
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
        require(success, "Refund failed");
    }

    ///@notice getDAIAddr returns the DAI token address
    function getDAIAddr() external view returns (address){
        return DAI_ADDR;
    }

    ///@notice getWETHAddr returns the WETH token address
    function getWETHAddr() external view returns (address) {
        return WETH_ADDR;
    }


///@notice _deposit function will Wrap ETH and hold the WETH amount to use for the DAI swap.
///@dev the contract deson't transfer WETH back to the sender, it holds it.
function  _deposit(uint _amountToUse) internal  {
    console.log("Depositing caller's ETH amount to use ...");
    weth.deposit{value: _amountToUse}();

}

  function _wethBal(address account) internal view returns (uint) {
    return weth.balanceOf(account);
  }
  function _daiBal(address account) internal view returns (uint) {
    return dai.balanceOf(account);
  }


    ///@notice getContractBalance , returns the balance of the contract
    ///@dev onlyOwner modifier ensures that only the deployer can make this query
    function getContractBalance() external view onlyOwner returns (uint) {
        return address(this).balance;
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


    ///@notice getDAIBalance , returns the WETH balance of the contract
    ///@param account, balance of account address is returned
    function getDAIBalance(address account) external view returns (uint) {
        return _daiBal(account);
    }




    }