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
    address  public immutable DAI;
    address  public immutable WETH;
    address private _owner;
    uint24 constant poolFee = 3000; //0.01% DAI/GETH pool
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
        WETH = (WETH_);
        DAI = DAI_;
        swapRouter = _swapRouter;
        _owner = msg.sender;
    }

  

  function WrapAllETH() external payable {

    console.log("ETH being wrapped...", msg.value);
    uint balanceBefore = IWETH(WETH).balanceOf(msg.sender);
    console.log("Initial Balance:",balanceBefore);
    IWETH(WETH).deposit{value: msg.value};
    IWETH(WETH).approve(address(this),msg.value);
    uint amountInWETH = IWETH(WETH).balanceOf(msg.sender);

    IWETH(WETH).transferFrom(WETH,address(this),amountInWETH);
    IWETH(WETH).approve(address(swapRouter), msg.value );
    uint getRouterAllowance = IWETH(WETH).allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);
    emit Deposit(msg.sender, msg.value);
  }


    function WrapSomeETH(uint amountToUse) external payable {
    
    console.log("Amount Sent:", msg.value);
    console.log("Amount To use:", amountToUse);
    _refund(msg.sender, amountToUse, msg.value);

    console.log("ETH being wrapped...", amountToUse);

    IWETH(WETH).deposit{value: amountToUse};
    IWETH(WETH).approve(address(this),amountToUse);

    IWETH(WETH).transferFrom(WETH,address(this),IWETH(WETH).balanceOf(msg.sender));
    IWETH(WETH).approve(address(swapRouter), amountToUse );
    uint getRouterAllowance = IWETH(WETH).allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);
    emit Deposit(msg.sender, msg.value);
  }

    /// @notice UnWrap deposited ETH, update
    ///@param amount withdraw amount requested by the caller 
    ///@dev checks if balance is greater than amount and emits Withdraw event
    function UnWrapWETH(uint amount) external payable {
        // IWETH(WETH).approve(address(this), amount);
        // IWETH(WETH).transferFrom(msg.sender, address(this),amount);
        // IWETH(WETH).withdraw(amount);
        // console.log("Contract balance:", address(this).balance);
        // _sendETH(msg.sender, address(this).balance);
        // emit Withdraw(msg.sender, amount);
    }


    /// @notice swap accepts user funds in msg.value
    /// @dev returns the excess value ETH back to the sender (amountToUse - msg.value)    
    function Swap(uint amountToSwap) external payable returns (uint amountOut) {

        IERC20(WETH).transferFrom(msg.sender,address(this), amountToSwap);
        IERC20(WETH).approve(address(swapRouter),amountToSwap);

        // uint payeeBalance = WETH9(GETH).balanceOf(_payee);

        // console.log("Balance of this payee", payeeBalance);

        // _refund(_payee,amountToUse,amountSent);
     
        // IFusionToken(GETH).approve(address(this), amountSent );
        
        // uint contractBalance = IFusionToken(GETH).balanceOf(address(this));
        // console.log("Balance of this contract", address(this).balance);
        // uint contractAllowance = IFusionToken(GETH).allowance(_payee,address(this));
        // console.log("Contract Allowance",contractAllowance);

        // uint amountGWETH = IFusionToken(GETH).balanceOf(address(this));
        // console.log("Balance of address(this) after",amountGWETH);
      
        // IFusionToken(GETH).approve(address(swapRouter), address(this).balance );
        // uint getRouterAllowance = IFusionToken(GETH).allowance(address(this),address(swapRouter));
        // console.log("Swap Router's allowance updated to:",getRouterAllowance);

        // amountOut = _swap(amountSent);
        // console.log("amountOut DAI:", amountOut);
        // emit SwapCompleted(amountOut);
        
 

    }

    /// @notice _swap internal function 
    /// using the DAI/GWETH 0.01% pool by calling the 
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @param _amountOut maximum possible output of WET or DAI received
    ///
    function _swap(uint amountIn) internal returns (uint _amountOut) 
    {
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : WETH,
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



    /// @notice _deposit, internal function that handles depositing the funds from the depositer
    /// @param _payee: the address of the account depositing the funds
    /// @dev emits a Deposit event after updating the balances
    function _deposit(address payable _payee, uint amountToUse) internal virtual  {
        _depositBal[_payee] = _depositBal[_payee].add(amountToUse);
        emit Deposit(_payee,amountToUse);
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