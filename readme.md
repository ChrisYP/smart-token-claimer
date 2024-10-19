# SmartToken Claim 脚本 
![twitter](https://img.shields.io/twitter/follow/0xNaiXi?style=social)
![twitter](https://img.shields.io/twitter/follow/ChrisNoCaptcha?style=social)


## 介绍
这是一个用于自动SmartToken的脚本,并自动把代币转到你的合约钱包中。

合约代码使用 最小代理miniProxy, 通过最低gas的创建合约地址,用于批量claim代币。  
在 `creatMiniProxy`方法中,你可以预先创建一些代理合约,避免领取代币时,高gas费造成的高额手续费。
在 `withdrawToken`方法中,检查了接收地址是否为合约地址,如果是合约地址,则会调用合约的 `transfer`方法,把代币转到合约地址中。否则会报错。
在 `mint_d22vi9okr4w`方法中,读取已经创建的代理合约,并领取代币。如果领取代币为0,则报错。后续交易该代理合约依旧可用,无需再次创建。


## 使用前准备
1. https://wallet.coinbase.com/settings/manage-wallets 点击 `Create smart wallet` 创建一个 合约钱包
2. 使用创建好的地址,随便发起一笔交易保证合约钱包被部署
3. 安装nodejs,并且在代码目录下执行 `npm install` 安装依赖
4. 修改 `index.js` 中的 `PRIVATEKEY` 为你的私钥, `RPC` 为你的rpc地址, `AA_WALLET` 为你的合约钱包地址, `maxFeePerGas` 为你的最大手续费,`maxPriorityFeePerGas` 为你的最大优先手续费
5. https://basescan.org/address/0x29d3f65677a8b2fd848ccb069e564f0cc9a745f9#writeContract#F2 通过这个链接,调用 `creatMiniProxy`方法,使用正常的低gas提前创建一些代理合约用于领取代币。其中 `toAddress` 为你的合约钱包地址, `_num` 为你预先创建的代理合约数量
## 启动
1. 执行 `node index.js` 即可开始自动领取

## 请我一杯咖啡

如果你觉得这个项目对你有帮助，可以请我喝一杯咖啡，谢谢！

SOL地址: EfDZm8wdkFU7JD8ACeWeJ54xaBVPWiZUKKmLSkN6WUzu

evm地址: 0xD70C7F06C07152Acb16D20012572250F57EEA624
