
## 操作步骤
### 1.部署业务逻辑合约：
- ERC20LogicVersion1.sol


### 2.部署工厂合约 
- Factory.sol

### 3.调用工厂合约创建可升级的erc20Token合约
- 调用createProxy传入第一步创建的可升级erc20合约地址
- 创建成功之后，点击logicProxy查看生成之后的代理地址


### 4.升级当前的erc20合约
- 打开工厂合约调用updateLogicProxy传入新合约的地址，即可完成升级. 


## 升级注意事项
1.插槽的冲突风险
2.升级之后继承关系



## 总结
合约升级风险会比较大，尽量严谨，并且升级要做到只增不减不修改.
以上就是今天要讲的内容，本文仅仅简单介绍了delegateCall的升级使用，关于安全方面还是需要自行根据业务去加限制，如有其他不正确的欢迎指出，或者DM



- 1.支持UUPS合约升级：对用户无感，使用委托调佣代理合约方式实现，保留存储和余额的同时，而又可以任意更改在地址中执行代码的操作
>* code is law，部署后无法修改
>* 合约功能修改
>* bug修复
>* 风险：
>>* 选择器冲突(透明代理)
以太坊中的所有函数调用都由有效载荷payload前4个字节来标识，称为“函数选择器”。选择器是根据函数名称及其签名的哈希值计算得出的。然而，4字节不具有很多熵，这意味着两个函数之间可能会发生冲突：具有不同名称的两个不同函数最终可能具有相同的选择器。如果你偶然发现这种情况，Solidity编译器将足够聪明，可以让你知道，并且拒绝编译具有两个不同函数名称，但具有相同4字节标识符（函数选择器）的合约。
~~~c++
// 这个合约无法通过编译，两个函数具有相同的函数选择器
contract Foo {
    function collate_propagate_storage(bytes16) external { }
    function burn(uint256) external { }
}
~~~
解决：
1.开发用于可升级智能合约的适当工具解决
2.通过代理本身解决：将代理设置为仅管理员能调用升级管理函数，而所有其他用户只能调用实现合约的函数，则不可能发生冲突。
3.配合**ProxyAdmin**合约使用
4.缺点： gas 成本。每个调用都需要额外的从存储中加载admin地址，这个操作在去年的伊斯坦布尔分叉之后变得更加昂贵。此外，与其他代理相比，该合约本身的部署成本很高， gas 超过70万。
~~~c++
// Sample code, do not use in production!
contract TransparentAdminUpgradeableProxy {
    address implementation;
    address admin;

    fallback() external payable {
        require(msg.sender != admin);
        implementation.delegatecall.value(msg.value)(msg.data);
    }

    function upgrade(address newImplementation) external {
        if (msg.sender != admin) fallback();
        implementation = newImplementation;
    }
}
~~~

>>* UUPS(通用的可升级代理标准)
1.该标准使用相同的委托调用模式，但是将升级逻辑放在实现合约中，而不是在代理本身中。
2.UUPS建议所有实现合约都应继承自基础的“可代理proxiable”合约:请记住，由于代理使用委托调用，因此实现合约始终会写入代理的存储中，而不是写入自己的存储中。实现地址本身保留在代理的存储中。并且修改代理的实现地址的逻辑同样在实现逻辑中实现
~~~c++
// Sample code, do not use in production!
contract UUPSProxy {
    address implementation;

    fallback() external payable {
        implementation.delegatecall.value(msg.value)(msg.data);
    }
}

abstract contract UUPSProxiable {
    address implementation;
    address admin;

    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}
~~~
3.通过在实现合约上定义所有函数，它可以依靠Solidity编译器检查任何函数选择器冲突。此外，代理的大小要小得多，从而使部署更便宜。在每次调用中，从存储中需要读取的内容更少，降低了开销
4.果将代理升级到没有可升级函数的实现上，那就永久锁定在该实现上，无法再更改它。一些开发人员更喜欢保持可升级逻辑不变，以防止出现这些问题，而这样做的最佳方式是放在代理合约本身


>>* 代理存储冲突和非结构化存储(可升级合约缺陷隐患)
在所有代理模式变体中，代理合约都需要至少一个状态变量来保存实现合约地址。默认情况下，Solidity存储变量在智能合约存储中的顺序是：声明的第一个变量移至插槽0，第二个变量移至插槽1，依此类推(映射和动态大小数组是此规则的例外)。这意味着，在以下代理合约中，实现合约地址将保存到存储插槽零。
~~~c++
// Sample code, do not use in production!
contract Proxy {
    address implementation;
}

// Sample code, do not use in production!
contract Box {
    address public value;

    function setValue(address newValue) public {
        value = newValue;
    }
}

// 尽管有效，但它有一个缺点，即要求所有委托目标合约都添加此额外的虚拟变量。这限制了可重用性，因为普通合约不能用作实现合约。这也容易出错，因为很容易忘记在合约中添加该额外变量
// Sample code, do not use in production!
contract Box {
    address implementation_notUsedHere;
    address public value;

    function setValue(address newValue) public {
        value = newValue;
    }
}

// 为避免此问题，非结构化存储模式被引入。此模式模仿Solidity如何处理映射和动态大小的数组：它不是将实现地址变量存储在第一个插槽中，而是存储在存储中的任意插槽中，确切地说是0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc。由于合约的可寻址存储大小为2 ^ 256，因此发生冲突的机会实际上为零。
// Sample code, do not use in production!
contract Proxy {
    fallback() external payable {
        address implementation = sload(0x360894...382bbc);
        implementation.delegatecall.value(msg.value)(msg.data);
    }
}
// 这样，实现合约业务逻辑将使用存储的第一个插槽，而代理将使用更高的插槽以避免任何冲突。出于工具性目的，EIP1967中已对委托调用代理所使用的插槽进行了标准化。这允许诸如Etherscan浏览器能轻松识别这些代理(因为在该特定插槽中具有类似地址值的任何合约很可能是代理)并解析出对应的合约的地址。
// 这种模式有效地解决了实现合约中的任何存储冲突问题，除了代理实现的额外复杂性外，没有任何缺点。
~~~


>>* 存储布局与追加存储和永久存储的兼容性