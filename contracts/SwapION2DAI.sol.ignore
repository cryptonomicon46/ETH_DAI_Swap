
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;
// import "./UniSwap.sol";
import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFusionToken.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./FusionToken.sol";
 

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol';

contract SwapETH2DAI {
    ISwapRouter public immutable swapRouter;
    using SafeMath for uint;
    IFusionToken IFUS20;
    address public immutable DAI;
    address public immutable WETH9;
    address public immutable ION;
    uint24 constant poolFee = 3000;
    address private _owner;
    mapping (address => uint) private _depositBal;


    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    struct Desposit {
        address owner,
        uint128 liquidity,
        address token0,
        address token1
    }

    mapping (uint256 => Deposit) public deposits;

    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint _amount);
    event Received(address _sender, uint _value);
    event Deposit(address _payee, uint _value);
    event Withdraw(address _payee, uint _value);
    event Refund(address _refunder, uint _value);
    event NoRefund();
    constructor(address ION_, 
            address DAI_,
            ISwapRouter _swapRouter,
            INonfungiblePositionManager _nonfungiblePositionManager) {
        ION = ION_;
        DAI = DAI_;
        swapRouter = _swapRouter;
        _owner = msg.sender;
        nonfungiblePositionManager = _nonfungiblePositionManager;
    }

     // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information

        _createDeposit(operator, tokenId);

        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) =
            nonfungiblePositionManager.positions(tokenId);

        // set the owner and data for position
        // operator is msg.sender
        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }


   /// @notice Calls the mint function defined in periphery, mints the same amount of each token.
    /// For this example we are providing 1000 DAI and 1000 USDC in liquidity
    /// @return tokenId The id of the newly minted ERC721
    /// @return liquidity The amount of liquidity for the position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mintNewPosition()
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint256 amount0ToMint = 1;
        uint256 amount1ToMint = 1;

        // transfer tokens to contract
        IFUS20.transferFrom(DAI, msg.sender, address(this), amount0ToMint);
         IFUS20.transferFrom(ION, msg.sender, address(this), amount1ToMint);

        // Approve the position manager
        TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: DAI,
                token1: USDC,
                fee: poolFee,
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: amount0ToMint,
                amount1Desired: amount1ToMint,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Create a deposit
        _createDeposit(msg.sender, tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(DAI, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(USDC, msg.sender, refund1);
        }
    }

    /// @notice SwapETHToDai accepts user funds in msg.value
    /// @param amountToUse, the amount of ETH to use to conver to DAI , refund the balance
    /// @dev returns the excess value ETH back to the sender (amountToUse - msg.value)    
    function SwapETHToDai(uint amountToUse) external payable returns (uint amountOut) {
        // require(msg.value > 0.1 ether, "ETH_VALUE_TOO_LOW");

        require(msg.value >= amountToUse, "Swap input value error");
        console.log("Input ETH Amount=", msg.value);

        //Issue a refund if account sent more ETH than they intended to swap in amountToUse variable
        refund(msg.sender, amountToUse);
      //  console.log(refund(msg.sender, amountToUse));


        //Deposit the funds 
        deposit(msg.sender, amountToUse);


        //How to convert the incoming ETH to WETH?
        //Create an ERC20 Token called Fusion token. 
        //Upon contract creation, mint FUSION tokens to the owner
        //User sends ETH to the Swap contract, update the balances mapping
        //Create a FUSION/DAI pool on Uniswap testnet
        //Complete the swap  Fusion ERC20 and gets FUSION tokens.
        // Create a pool for FUSION/DAI on Uniswap test net
        //Use this pool to swap out FUSION for DAI
        // Return DAI to the owner along with any ETH balance that wasn't used 

        IWETH(WETH9).deposit{value: msg.value }();
        IFUS20(WETH9).approve(address(this), msg.value);

        uint amountInWETH = IERC20(WETH9).balanceOf(msg.sender);

        IFUS20(WETH9).transferFrom(WETH9,address(this),amountInWETH);
        amountInWETH = IERC20(WETH9).balanceOf(address(this));
        console.log("Balance of address(this) after",amountInWETH);
      
        IFUS20(WETH9).approve(address(swapRouter), amountInWETH );
        uint getRouterAllowance = IFUS20(WETH9).allowance(address(this),address(swapRouter));
        console.log("Swap Router's allowance updated to:",getRouterAllowance);

        amountOut = _swapWETHForDai(amountInWETH);
        console.log("amountOut:", amountOut);
        emit SwapCompleted(amountOut);
        
 
        //Refund event

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
                tokenIn : ION,
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


    /// @notice deposit, public function , can only be called by the owner, that handles depositing the funds from the depositer
    /// @param _payee: the address of the account depositing the funds
    /// @param _value: the amount to deposit from the depositer
    /// @dev emits a Deposit event after updating the balances
    function deposit(address _payee, uint _value) public payable onlyOwner() returns (bool) {
        _deposit(_payee, _value);
        return true;
    }


    /// @notice _deposit, internal function that handles depositing the funds from the depositer
    /// @param _payee: the address of the account depositing the funds
    /// @dev emits a Deposit event after updating the balances
    function _deposit(address _payee, uint _value) internal virtual payable {
        require(msg.value>= "0.1 ether", "INVALID_DEPOSIT_AMOUNT");

        _depositBal[_payee] = _depositBal[_payee].add(value);
        Deposit(_payee,msg.value);
    }

    ///@notice refund, top level function that calls an internal function to check if account receives a refund, returns true
    ///@param account, the account that'll receive the excess refund
       function refund(address account, uint value) public payable returns (bool) {
        _refund(account,value);
        return true;
    }



    ///@notice _refund, internal function that handles the sending the excess ETH refund
    ///@param account, the account that'll receive the excess refund
    ///@dev emits either a Refund or NoRefund event
    function _refund(address account, uint amountToUse) internal payable {
        if (msg.value > amountToUse) {
            uint amountToRefund = (msg.value).sub(amountToUse);
            sendETH(account,amountToRefund);'
            emit Refund(account,value);
        } else if (msg.value = amountToUse) {
            emit NoRefund();
        }

    }


    ///@notice sendETH public function to send ETH, called an internal function
    ///@param account: payable account that'll get the refund in ETH
    ///@param _value: amount of ETH to be refunded to the account
    ///@return boolean: true if the operation is successful
    function sendETH(address payable account, uint _value) public payable returns (bool){
        _sendEth(account,_value);
        return true;
    }
    ///@notice _sendETH internal function to handle sending ETH, emits Refund event
    ///@param account: payable account that'll get the refund in ETH
    ///@param _value: amount of ETH to be refunded to the account
    ///@return boolean: true if the operation is successful
    function _sendETH(address payable account, uint _value) internal payable {
        (bool success, ) = payable(account).call{value: _value}("");
        require(success, "Refund didn't go through successfully");
    }

    /// @notice withdraw, allows users to withdraw their funds in case the swap doesn't go through
    /// @param _payee: the address of the account withdrawing funds
    /// @dev Checks-Effects-Interactions pattern implemented to avoid reentrancy
        function withdraw(address _payee) public payable returns (bool){
            _withdraw(_payee);
            return true;
    } 


    /// @notice _withdraw, internal function that does a low level call to transfer balances, emits Withdraw event
    /// @param _payee: the address of the account withdrawing funds
    /// @dev Checks-Effects-Interactions pattern implemented to avoid reentrancy
        function _withdraw(address _payee) internal virtual payable {
        require(_payee != address(0),"INVALID_ACCOUNT");
        require(_depositBal[_payee]>= 0,"NOTHING_TO_WITHDRAW");
        uint _bal  = _depositBal[_payee];
        _depositBal[_payee] = 0;
        (bool success, ) = payable(_payee).call{value: _bal};
        require(success);
        Withdraw(_payee,_bal);
    } 
    }