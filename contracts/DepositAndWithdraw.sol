
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
import "hardhat/console.sol";
import "./IWETH.sol";


/**
 * @notice DepositAndWithdraw WRAPS and UNWRAPS ETH for the sender
 * Wrapping ETH: Deposit the user's ETH into the WETH contract and transfer the WETH back to the user
 * UNWrapping ETH: Withdraw user's original ETH based on the WETH balance
 *
 */

contract DepositAndWithdraw  {
    using SafeMath for uint256;
    address private WETH_ADDR;
    bool internal _locked;
    IWETH weth;
    address private _owner;



    /**
     * userETHBal holds the cumulative balance for the user to withdraw
     */
    mapping (address => uint256) public userETHBal;

    /**
     * Deposited event emitted when sender's ETH has been deposited into the WETH contract
     */
    event Deposited(uint amount);

    /**
     * withdraw event emitted when the sender requests to withdraw the original ETH amount from the WETH contract
     */
    event withdraw(uint wad);
    /**
     * SafeWithdraw emitted when the owner withdraws his/her ETH
     */
    event SafeWithdraw(address _to, uint256 value);


    /**
     * modifier to check if msg.sender is the owner of the contract
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    /**
     * Reentrancy guard modifier
     */

    modifier noReentrancy() {
        _locked = true;
        _;
        _locked = false;
    }
    constructor(address WETH_ADDR_) payable {
        WETH_ADDR = WETH_ADDR_;
        weth = IWETH(WETH_ADDR);
        _owner = msg.sender;
    }


    /**
     * @notice Deposit function will WRAP (or deposit senders's 
     * ETH into the WETH contract) and transfer back the resulting WETH
     * 
     * @dev emits a deposit event 
     */
    function  Deposit() external payable {
        uint amount = msg.value;
        weth.deposit{value: msg.value}();
        weth.transfer(msg.sender,amount);
        emit Deposited(msg.value);
        }


    /**
     *  @notice Withdraw will convert the sender's WETH balance to ETH and transfer it back to the sender
     * @param wad is the amount the user wishes to withdraw
     * @dev Checks and effects pattern used, balances variables are updated
     * before doing a low level call to transfer the sender's ETH funds
     * 
     */
    function Withdraw(uint256 wad) external {
        require(weth.balanceOf(msg.sender)>= wad, "DepositAndWithdraw: Insufficient WETH balance in the WETH contract!");
        weth.transferFrom(msg.sender, address(this),wad);
        weth.withdraw(wad);
        userETHBal[msg.sender] = userETHBal[msg.sender].add(wad);
        emit withdraw(wad);
    }


    /**
     *  @notice safeWithdraw is a Reentrancy guarded function that allows the user to withdraw the ETH balances
     * @param value is the amount of ETH in balance that the user wishes to withdraw
     * @dev Checks and effects pattern used, balances variables are updated
     * before doing a low level call to transfer the sender's ETH funds
     * 
     */  
 function safeWithdraw( uint256 value) external payable noReentrancy returns (bool) {
        require( value<= address(this).balance, "DepositAndWithdraw: Insufficient ETH Balance in the contract!");
        userETHBal[msg.sender] = userETHBal[msg.sender].sub(value);
        (bool success, ) = payable(msg.sender).call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
        emit SafeWithdraw(msg.sender, value);
        return true;
    }


    /**
     * getUserETHBalance returns the user's ETH balance to be withdrawn 
     */
    function getUserETHBalance() external view onlyOwner returns (uint256) {
        return (userETHBal[msg.sender]);
    }

    /**
     * getContractETHBalance returns this contracts ETH balance 
     */
    function getContractETHBalance() external view onlyOwner returns (uint256) {
        return (address(this).balance);
    }


    /**
     * getContractWETHBalance returns the WETH balance of this contract
     */
    function getContractWETHBalance() external view returns (uint256) {
        return _wethBal(address(this));
    }


    /**
     * getWETHBalance returns the WETH balance of the contract
     * @param account, balance of account address is returned
     */
    function getWETHBalance(address account) external view returns (uint256) {
        return _wethBal(account);
    }



    /**
     * getETHBalance retrieves the ETH balance of the account
     * @param account is the account address
     */
    function getETHBalance(address account) external view returns (uint256) {
        return account.balance;
    }

    /**
     * Internal function that queries the WETH balance for an account
     */
    function _wethBal(address account) internal view returns (uint256) {
        return weth.balanceOf(account);
    }


    /**
     * getWETHAddr returns the address of the WETH mainnet or testnet contract address passed into the constructor of this contract.
     */
    function getWETHAddr() external view returns (address) {
        return WETH_ADDR;
    }

    ///@notice getOwner returns the address that deployed the contract
    function getOwner() external view returns (address) {
        return _owner;
    }
  receive() external payable {}
}
