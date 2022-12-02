async function main() {
    const accounts = await ethers.getSigners();
    for (const account of accounts) {
        console.log(account.address,":",ethers.utils.formatEther(await account.getBalance()));
    }
}

main().catch((error) => {
        console.error(error);
        process.exit(1);
});



