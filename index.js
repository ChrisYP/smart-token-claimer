const ethers = require('ethers');
const Logger = require("@youpaichris/logger");
const logger = new Logger();

const PRIVATEKEY = "你的私钥"
const RPC = "https://rpc.ankr.com/base"
const AA_WALLET = "0xA42a1864Ef6866458bEb30f89BE44dB4DA94a5B6" // 这里填写你的合约钱包地址  务必 填写eoa钱包地址会报错
let maxFeePerGas = ethers.utils.parseUnits("40", "gwei");
let maxPriorityFeePerGas = ethers.utils.parseUnits("1", "gwei");
if(!RPC) {
    logger.error("RPC URL is required");
    process.exit(1);
}
if(!ethers.utils.isAddress(AA_WALLET)){
    logger.error("AA_WALLET is required");
    process.exit(1);
}

const abiText = `[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"clone","type":"address"},{"indexed":false,"internalType":"address","name":"owner","type":"address"}],"name":"NewClone","type":"event"},{"inputs":[],"name":"claimSmartToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"}],"name":"getBalanceToken","outputs":[{"internalType":"uint256","name":"balance","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"toAddress","type":"address"}],"name":"mint_d22vi9okr4w","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"index","type":"uint256"}],"name":"proxyFor","outputs":[{"internalType":"address","name":"predicted","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"}],"name":"withdrawBNB","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"to","type":"address"}],"name":"withdrawToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]`
const abi = JSON.parse(abiText);
const iface = new ethers.utils.Interface(abi);
const provider = new ethers.providers.JsonRpcProvider(RPC);
let nonce = 0
async function claim(privateKey){
    const wallet = new ethers.Wallet(privateKey, provider);
    nonce = await provider.getTransactionCount(wallet.address);
    logger.info(`wallet address: ${wallet.address}`);
    const inputData = "0x00000000000000000000000000000000a42a1864ef6866458beb30f89be44db4da94a5b6"
    // const inputData = iface.encodeFunctionData("mint_d22vi9okr4w", [AA_WALLET]);
    while (true){
        try{
            // await getLastBlockMaxGasPrice();
            //广播交易
            const tx = {
                from: wallet.address,
                nonce: nonce,
                gasLimit: "200000",
                maxFeePerGas: maxFeePerGas,
                maxPriorityFeePerGas: maxPriorityFeePerGas,
                data: inputData,
                to: "0x29D3F65677A8b2fD848cCb069e564F0cC9a745f9",
                chainId: 8453,
                value: 0,
                type: 2
            };
            const signedTx = await wallet.signTransaction(tx);
            const result = await provider.sendTransaction(signedTx);
            nonce++;
            logger.info(`${wallet.address} 广播交易成功: ${result.hash}`);
            //延迟 1秒
            await new Promise((resolve) => setTimeout(resolve, 1000));
            // return result;
        }catch (error) {
            // console.log(`claim error:`,error);
            logger.error(`claim error: ${error.reason}`);
        }
    }
}


async function getLastBlockMaxGasPrice(){
    const block = await provider.getBlock("latest");
    const lastTx = block.transactions[1];
    const tx = await provider.getTransaction(lastTx);
    if(tx.type === 2){
        maxFeePerGas = Math.floor(tx.maxFeePerGas * 1.2)
        maxPriorityFeePerGas = Math.floor(tx.maxPriorityFeePerGas * 1.2)
    }else{
        maxFeePerGas = tx.gasPrice
        maxPriorityFeePerGas = maxFeePerGas
    }
}

async function main(){
    try {
        await claim(PRIVATEKEY)
    } catch (error) {
        console.error('Error swap:', error);
    }

}
main().catch(error => {
    logger.error(error);
});
