DepositAndWithdraw.sol

This contract handles the wrapping and unwrapping of ETH for the sender.

Deposit Instructions for the Sender:

1. Sender should hold an ETH balance to begin with.
2. Sender will deposit a desired amount of ETH in the contract by calling the 'Deposit()' function
3. Sender will then hold a WETH balance in the WETH contract.

Withdraw Instructions for the Sender:

1. Sender might want to unwrap WETH to hold an ETH balance.
2. Sender calls the 'Withdraw(uint256)' function by specifying the amount of WETH.
3. Sender can check the ETH balance by calling the 'getUserETHBalance()'
4. Sender then calls the 'safeWithdraw(uint256' which has the noReentrance guard, to withdraw funds.

Goerli TestNet
npx hardhat run scripts/2_deploy_DepositAndWithdraw.js --network goerli

npx hardhat verify "0x80865853E1f195445Fa33a9a99862c5071dCA518" "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6" --network goerli

Goerli Testnet Contract Address
https://goerli.etherscan.io/address/0x80865853E1f195445Fa33a9a99862c5071dCA518#code
