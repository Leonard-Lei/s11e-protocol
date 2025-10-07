# Demo 可升级合约完整指南

## 概述

Demo 合约是一个简单的可升级合约示例，演示了如何使用 Hardhat 的 `@openzeppelin/hardhat-upgrades`
插件来部署和升级智能合约。该合约提供了基本的存储和读取功能，DemoV2 版本在此基础上增加了递增功能。

## 合约架构

### Demo (V1)

**功能**:

- 存储一个 uint256 值
- 读取存储的值
- 可初始化设置初始值

**主要函数**:

- `initialize(uint256 value)` - 初始化合约
- `store(uint256 value)` - 存储新值
- `retrieve()` - 读取当前值

### DemoV2 (V2)

**新增功能**:

- 继承 Demo V1 的所有功能
- 新增 `increment()` 函数，可以将值加 1

**主要函数**:

- 继承 V1 的所有函数
- `increment()` - 将存储的值递增 1

## 目录结构

```
.
├── contracts/test/
│   ├── Demo.sol           # V1 合约
│   ├── DemoV2.sol         # V2 合约
│   └── Demo.md            # 本文档
├── test/demo/
│   ├── Demo.fixture.ts    # 测试夹具
│   ├── Demo.ts            # Demo V1 测试
│   └── DemoV2.ts          # DemoV2 测试
└── deploy/demo/
    ├── Demo.ts            # Demo V1 部署脚本
    └── DemoV2.ts          # DemoV2 升级脚本
```

## 环境准备

### 1. 安装依赖

确保项目已安装必要的依赖：

```bash
npm install --save-dev @openzeppelin/hardhat-upgrades
npm install --save-dev @openzeppelin/contracts-upgradeable
```

### 2. 配置 Hardhat

在 `hardhat.config.ts` 中导入插件：

```typescript
import "@openzeppelin/hardhat-upgrades";
```

### 3. 环境变量

创建 `.env` 文件（如果需要部署到测试网或主网）：

```bash
MNEMONIC="your mnemonic phrase"
INFURA_API_KEY="your infura api key"
```

## 合约代码说明

### Demo.sol

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Demo is Initializable {
  uint256 private _value;

  // 初始化函数，替代构造函数
  function initialize(uint256 value) public initializer {
    _value = value;
  }

  // 值变更事件
  event ValueChanged(uint256 value);

  // 存储新值
  function store(uint256 value) public {
    _value = value;
    emit ValueChanged(value);
  }

  // 读取存储的值
  function retrieve() public view returns (uint256) {
    return _value;
  }
}
```

**关键点**:

- 继承 `Initializable` 而不是普通合约
- 使用 `initialize` 函数代替 `constructor`
- `initializer` 修饰符确保只能初始化一次
- 状态变量必须在升级时保持存储布局兼容

### DemoV2.sol

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DemoV2 is Initializable {
  uint256 private _value;

  function initialize(uint256 value) public initializer {
    _value = value;
  }

  event ValueChanged(uint256 value);

  function store(uint256 value) public {
    _value = value;
    emit ValueChanged(value);
  }

  function retrieve() public view returns (uint256) {
    return _value;
  }

  // 新增功能：递增
  function increment() public {
    _value = _value + 1;
    emit ValueChanged(_value);
  }
}
```

**升级注意事项**:

- ✅ 可以添加新函数（如 `increment`）
- ✅ 可以添加新的状态变量（必须在现有变量之后）
- ❌ 不能修改现有状态变量的顺序
- ❌ 不能删除现有状态变量
- ❌ 不能修改现有状态变量的类型

## 测试

### 测试文件结构

#### Demo.fixture.ts

测试夹具，提供合约部署的可重用函数：

```typescript
import { ethers, upgrades } from "hardhat";

export async function deployDemoFixture() {
  const [owner, addr1, addr2] = await ethers.getSigners();
  const initialValue = 42;

  // 部署可升级的 Demo 合约
  const Demo = await ethers.getContractFactory("Demo");
  const demo = await upgrades.deployProxy(Demo, [initialValue], {
    initializer: "initialize",
  });
  await demo.waitForDeployment();

  const demoAddress = await demo.getAddress();

  return { demo, demoAddress, initialValue, owner, addr1, addr2 };
}
```

### 运行测试

#### 1. 运行所有 Demo 测试

```bash
# 运行 Demo V1 测试
npx hardhat test test/demo/Demo.ts

# 运行 DemoV2 测试
npx hardhat test test/demo/DemoV2.ts

# 运行所有 demo 测试
npx hardhat test test/demo/

# 带 Gas 报告
REPORT_GAS=true npx hardhat test test/demo/
```

#### 2. 测试覆盖

**Demo V1 测试（15 个测试）**:

```
Demo
  部署
    ✔ 应该正确初始化值
    ✔ 应该正确部署代理合约
    ✔ 不应该允许重复初始化
  存储功能
    ✔ 应该能够存储新值
    ✔ 应该触发 ValueChanged 事件
    ✔ 任何地址都应该能够存储值
    ✔ 应该能够覆盖之前的值
  读取功能
    ✔ 应该返回当前存储的值
    ✔ 读取不应该修改状态
  可升级性
    ✔ 应该能够升级到 DemoV2
    ✔ 升级后应该保留状态
    ✔ 升级后应该有新功能
```

**DemoV2 测试（14 个测试）**:

```
DemoV2
  升级后的部署
    ✔ 应该保留初始值
    ✔ 代理地址应该保持不变
  继承的功能
    ✔ 应该能够存储新值
    ✔ 应该触发 ValueChanged 事件
    ✔ 应该能够读取值
  新增的 increment 功能
    ✔ 应该能够递增值
    ✔ 应该触发 ValueChanged 事件
    ✔ 任何地址都应该能够递增
    ✔ 应该能够多次递增
    ✔ increment 和 store 应该能够配合使用
  状态保留测试
    ✔ 升级前设置的值应该在升级后保留
    ✔ 升级后修改的值应该正确存储
```

#### 3. 测试示例代码

```typescript
describe("Demo", function () {
  it("应该正确初始化值", async function () {
    const { demo, initialValue } = await loadFixture(deployDemoFixture);
    expect(await demo.retrieve()).to.equal(initialValue);
  });

  it("应该能够升级到 DemoV2", async function () {
    const { demo, demoAddress } = await loadFixture(deployDemoFixture);

    // 升级合约
    const DemoV2 = await ethers.getContractFactory("DemoV2");
    const upgraded = await upgrades.upgradeProxy(demoAddress, DemoV2);

    // 验证地址不变
    expect(await upgraded.getAddress()).to.equal(demoAddress);
  });
});
```

## 部署流程

### 方式一：使用部署脚本（推荐）

#### 1. 部署 Demo V1

```bash
# 部署到本地 Hardhat 网络
npx hardhat run deploy/demo/Demo.ts --network hardhat

# 部署到 localhost（需要先运行 npx hardhat node）
npx hardhat run deploy/demo/Demo.ts --network localhost

# 部署到 Sepolia 测试网
npx hardhat run deploy/demo/Demo.ts --network sepolia
```

**输出示例**:

```
开始部署 Demo 合约...

部署账户: 0x1234...
账户余额: 10.0 ETH

初始值: 42
正在部署 Demo 代理合约...

✅ Demo 代理合约部署成功!
代理合约地址: 0xABCD...
实现合约地址: 0xEF12...
管理员合约地址: 0x3456...

验证部署...
存储的值: 42
✅ 部署验证成功!

测试 store 功能...
新存储的值: 100
✅ store 功能测试成功!

==================== 部署信息汇总 ====================
网络: hardhat
代理合约地址: 0xABCD...
实现合约地址: 0xEF12...
管理员合约地址: 0x3456...
初始值: 42
当前值: 100
====================================================
```

**重要**: 保存代理合约地址，升级时需要使用！

#### 2. 升级到 DemoV2

```bash
# 设置环境变量（代理合约地址）
export DEMO_PROXY_ADDRESS=0xABCD...

# 升级合约
npx hardhat run deploy/demo/DemoV2.ts --network hardhat

# 或者一行命令
DEMO_PROXY_ADDRESS=0xABCD... npx hardhat run deploy/demo/DemoV2.ts --network hardhat
```

**输出示例**:

```
开始升级 Demo 合约到 DemoV2...

部署账户: 0x1234...
账户余额: 9.9 ETH

代理合约地址: 0xABCD...

获取升级前的状态...
升级前存储的值: 100

检查升级兼容性...
✅ 升级兼容性检查通过

正在升级合约...
✅ 合约升级成功!
新实现合约地址: 0x7890...

验证升级...
升级后存储的值: 100
✅ 状态保留验证成功!

测试新增的 increment 功能...
increment 后的值: 101
✅ increment 功能测试成功!

测试多次 increment...
最终值: 103

==================== 升级信息汇总 ====================
网络: hardhat
代理合约地址: 0xABCD...
新实现合约地址: 0x7890...
升级前的值: 100
升级后的值: 100
最终值: 103
新增功能: increment()
====================================================
```

### 方式二：使用 Hardhat Console

#### 1. 启动 Console

```bash
npx hardhat console --network localhost
```

#### 2. 部署 Demo V1

```javascript
// 获取合约工厂
const Demo = await ethers.getContractFactory("Demo");

// 部署代理
const demo = await upgrades.deployProxy(Demo, [42], {
  initializer: "initialize",
});
await demo.waitForDeployment();

// 获取地址
const demoAddress = await demo.getAddress();
console.log("代理地址:", demoAddress);

// 测试功能
console.log("当前值:", await demo.retrieve());
await demo.store(100);
console.log("新值:", await demo.retrieve());
```

#### 3. 升级到 DemoV2

```javascript
// 使用之前保存的代理地址
const proxyAddress = "0xABCD...";

// 获取 DemoV2 工厂
const DemoV2 = await ethers.getContractFactory("DemoV2");

// 升级
const demoV2 = await upgrades.upgradeProxy(proxyAddress, DemoV2);

// 测试新功能
console.log("升级后的值:", await demoV2.retrieve());
await demoV2.increment();
console.log("increment 后:", await demoV2.retrieve());
```

### 方式三：编程方式部署

创建自定义脚本：

```typescript
import { ethers, upgrades } from "hardhat";

async function deployAndUpgrade() {
  // 1. 部署 V1
  console.log("部署 Demo V1...");
  const Demo = await ethers.getContractFactory("Demo");
  const demo = await upgrades.deployProxy(Demo, [42], {
    initializer: "initialize",
  });
  await demo.waitForDeployment();
  const proxyAddress = await demo.getAddress();
  console.log("代理地址:", proxyAddress);

  // 2. 使用 V1
  await demo.store(100);
  console.log("V1 存储的值:", await demo.retrieve());

  // 3. 升级到 V2
  console.log("\n升级到 DemoV2...");
  const DemoV2 = await ethers.getContractFactory("DemoV2");
  const demoV2 = await upgrades.upgradeProxy(proxyAddress, DemoV2);
  console.log("升级后的值:", await demoV2.retrieve());

  // 4. 使用 V2 新功能
  await demoV2.increment();
  console.log("increment 后:", await demoV2.retrieve());

  return { proxyAddress, demo: demoV2 };
}

deployAndUpgrade()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

## 核心概念

### 1. 代理模式

```
用户调用
    ↓
代理合约 (Proxy) ← 管理员可以更改
    ↓ delegatecall
实现合约 (Implementation)
    ↓
存储在代理合约中
```

**关键点**:

- 代理合约地址永远不变
- 实现合约可以被替换
- 所有状态存储在代理合约
- 用户始终与代理合约交互

### 2. 透明代理 vs UUPS

本示例使用**透明代理**模式：

| 特性     | 透明代理           | UUPS         |
| -------- | ------------------ | ------------ |
| 升级逻辑 | 在代理合约中       | 在实现合约中 |
| Gas 成本 | 较高               | 较低         |
| 安全性   | 更高（管理员分离） | 需要小心实现 |
| 复杂度   | 较高               | 较低         |

### 3. 初始化器

```solidity
function initialize(uint256 value) public initializer {
  _value = value;
}
```

**为什么需要 initializer**:

- 代理合约不能使用 constructor
- initializer 确保只初始化一次
- 类似于 constructor 的作用

### 4. 存储布局

**正确示例** ✅:

```solidity
// V1
contract Demo {
  uint256 private _value; // slot 0
}

// V2 - 添加新变量
contract DemoV2 {
  uint256 private _value; // slot 0 (保持不变)
  uint256 private _newValue; // slot 1 (新增)
}
```

**错误示例** ❌:

```solidity
// V1
contract Demo {
  uint256 private _value;
}

// V2 - 错误：修改了顺序
contract DemoV2 {
  uint256 private _newValue; // ❌ 占用了原来 _value 的位置
  uint256 private _value;
}
```

## 常见问题和解决方案

### 1. 升级后状态丢失

**问题**: 升级后无法读取之前的值

**原因**: 存储布局不兼容

**解决方案**:

- 保持状态变量顺序不变
- 新变量添加在末尾
- 使用 `upgrades.validateUpgrade()` 检查

```typescript
await upgrades.validateUpgrade(proxyAddress, NewImplementation);
```

### 2. 重复初始化错误

**问题**: `InvalidInitialization` 错误

**原因**: 尝试再次调用 `initialize`

**解决方案**:

- 升级时不需要再次初始化
- 如需添加新状态，使用新的初始化函数

```solidity
function initializeV2(uint256 newValue) public reinitializer(2) {
  _newValue = newValue;
}
```

### 3. 升级权限问题

**问题**: 无权升级合约

**原因**: 当前账户不是管理员

**解决方案**:

- 使用部署时的账户
- 或转移管理员权限

```typescript
// 查看管理员
const admin = await upgrades.erc1967.getAdminAddress(proxyAddress);

// 转移管理员（小心使用！）
await upgrades.admin.transferProxyAdminOwnership(newAdmin);
```

### 4. 验证合约

部署后验证合约代码：

```bash
# 验证实现合约
npx hardhat verify --network sepolia <IMPLEMENTATION_ADDRESS>

# 验证代理合约
npx hardhat verify --network sepolia <PROXY_ADDRESS>
```

## 最佳实践

### 1. 开发流程

1. ✅ 编写 V1 合约
2. ✅ 编写完整测试
3. ✅ 本地部署和测试
4. ✅ 测试网部署
5. ✅ 验证合约
6. ✅ 审计（生产环境）
7. ✅ 主网部署

### 2. 升级流程

1. ✅ 编写 V2 合约
2. ✅ 确保存储布局兼容
3. ✅ 编写升级测试
4. ✅ 使用 `validateUpgrade` 检查
5. ✅ 测试网升级和验证
6. ✅ 审计（生产环境）
7. ✅ 主网升级

### 3. 安全建议

- ✅ 使用 `@openzeppelin/hardhat-upgrades` 的验证功能
- ✅ 在测试网充分测试
- ✅ 保持状态变量顺序不变
- ✅ 为管理员使用多签钱包
- ✅ 记录所有升级历史
- ✅ 准备降级方案
- ❌ 不要在生产环境直接删除状态变量
- ❌ 不要跳过兼容性检查

### 4. 文档化

记录每次升级：

```markdown
## 升级历史

### V1 -> V2 (2024-01-15)

- 新增 `increment()` 函数
- 代理地址: 0xABCD...
- V1 实现: 0xEF12...
- V2 实现: 0x7890...
```

## 进阶主题

### 1. 使用 UUPS 模式

修改合约使用 UUPS：

```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract DemoUUPS is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  uint256 private _value;

  function initialize(uint256 value) public initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
    _value = value;
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  // ... 其他函数
}
```

部署时使用 UUPS：

```typescript
const demo = await upgrades.deployProxy(Demo, [42], {
  initializer: "initialize",
  kind: "uups", // 指定使用 UUPS
});
```

### 2. 条件升级

只在特定条件下允许升级：

```solidity
uint256 public upgradeCount;
uint256 public constant MAX_UPGRADES = 5;

function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyOwner
{
    require(upgradeCount < MAX_UPGRADES, "Max upgrades reached");
    upgradeCount++;
}
```

### 3. 时间锁升级

添加升级延迟：

```solidity
uint256 public upgradeProposedTime;
uint256 public constant UPGRADE_DELAY = 2 days;
address public pendingImplementation;

function proposeUpgrade(address newImplementation) public onlyOwner {
    pendingImplementation = newImplementation;
    upgradeProposedTime = block.timestamp;
}

function executeUpgrade() public onlyOwner {
    require(
        block.timestamp >= upgradeProposedTime + UPGRADE_DELAY,
        "Upgrade delay not passed"
    );
    _authorizeUpgrade(pendingImplementation);
}
```

## 相关资源

### 官方文档

- [OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/)
- [OpenZeppelin Upgradeable Contracts](https://docs.openzeppelin.com/contracts/4.x/upgradeable)
- [Hardhat](https://hardhat.org/)

### 代码仓库

- [OpenZeppelin Contracts Upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable)
- [OpenZeppelin Hardhat Upgrades](https://github.com/OpenZeppelin/openzeppelin-upgrades)

### 相关文档

- [可升级合约指南](../../doc/UpgradwableContract.md)
- [StandardERC20 文档](../extensions/token/standard/StandardERC20.md)

## 总结

本指南完整介绍了：

1. ✅ Demo 合约的结构和功能
2. ✅ 完整的测试套件（29 个测试）
3. ✅ 三种部署方式（脚本、Console、编程）
4. ✅ 升级流程和注意事项
5. ✅ 常见问题和解决方案
6. ✅ 最佳实践和安全建议
7. ✅ 进阶主题（UUPS、条件升级、时间锁）

通过本示例，您应该能够：

- 理解可升级合约的工作原理
- 正确部署和升级合约
- 避免常见的陷阱
- 编写安全的升级代码

## 许可证

MIT License
