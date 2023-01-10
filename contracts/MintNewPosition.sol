// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol';

contract MintNewPosition is IERC721Receiver {

    address public constant GDAI = 0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4;
    address public constant DAI = 0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60;
    address public constant ION = 0xa28Aae128E9193D659De6d25e4979499c41E9c19;
    address public constant WETH_TEST = 0x91761E31588ddB57386225055cE2B993Ae07081f;
    address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public constant NonfungiblePositionManagerADDR = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    uint24 public constant poolFee = 3000;
    INonfungiblePositionManager public immutable  nonfungiblePositionManager;
  struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    mapping(uint256 => Deposit) public deposits;
// GDAI /WETH pool created using the NonFungiblePositionManager's 'createAndInitializePoolIfNecessary'
// Pool address 
//  0x1aC7982148eb00d2AaE341326bbAA3952556C119
// MintParams (Mint a new position GDAI/WETH)
// (0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4,0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6,3000,-887272,-887272,100,0.01,0,0,0xC36442b4a4522E871399CD717aBDD847Ab11FE88,1672358676)


   constructor(
        // INonfungiblePositionManager _nonfungiblePositionManager
    ) {
        nonfungiblePositionManager = INonfungiblePositionManager(NonfungiblePositionManagerADDR);
    }

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
        (address token0, address token1,uint128 liquidity ) =
            nonfungiblePositionManager.positions1(tokenId);

    //     // set the owner and data for position
    //     // operator is msg.sender
        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }


    /// @notice Calls the mint function defined in periphery, mints the same amount of each token. For this example we are providing 1000 DAI and 1000 USDC in liquidity
    /// @param token0 address 
  /// @param token1 address 
   /// @param amount0ToMint amount of token0 to mint
   /// @param amount1ToMint amount of token1 to mint 
    /// @return tokenId The id of the newly minted ERC721
    /// @return liquidity The amount of liquidity for the position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mintNewPosition(address token0, address token1,uint amount0ToMint, uint amount1ToMint)
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
        // uint256 amount0ToMint = 500;
        // uint256 amount1ToMint = 1;

        // Approve the position manager
        TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
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
            TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(token0, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(token1, msg.sender, refund1);
        }
    }



    /// @notice Calls the mint function defined in periphery, mints the same amount of each token. For this example we are providing 1000 DAI and 1000 USDC in liquidity
   /// @param amount0ToMint amount of token0 to mint
   /// @param amount1ToMint amount of token1 to mint 
    /// @return tokenId The id of the newly minted ERC721
    /// @return liquidity The amount of liquidity for the position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mintNewPositionGDAI_WETH(uint amount0ToMint, uint amount1ToMint)
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
        // uint256 amount0ToMint = 500;
        // uint256 amount1ToMint = 1;

        // Approve the position manager
        TransferHelper.safeApprove(GDAI, address(nonfungiblePositionManager), amount0ToMint);
        TransferHelper.safeApprove(WETH, address(nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: GDAI,
                token1: WETH,
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
            TransferHelper.safeApprove(GDAI, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(GDAI, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(WETH, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(WETH, msg.sender, refund1);
        }
    }


    function getGDAIAddress() external pure returns (address) {
        return GDAI;
    }


    function getDAIAddress() external pure returns (address) {
        return DAI;
    }
    function getWETHAddress() external pure returns (address) {
        return WETH;
    }

    function getIONAddress() external pure returns (address) {
        return ION;
    }

    function getWETHTestAddress() external pure returns (address) {
        return WETH_TEST;
    }

    
}

