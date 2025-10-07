# UpgradeableERC20 部署脚本

## 概述

完整的 UpgradeableERC20 可升级代币部署和升级脚本集合。

## 文件结构

```
deploy/upgradeable_erc20/
├── UpgradeableERC20.ts        # V1 部署脚本
├── UpgradeableERC20V2.ts      # V2 升级脚本
├── DeployAndUpgrade.ts        # 组合脚本（一次性部署和升级）
└── README.md                  # 本文档
```

## 使用方法

### 方式一：组合脚本（推荐 ⭐）

**一次性完成 V1 部署和 V2 升级**：

```bash
npx hardhat run deploy/upgradeable_erc20/DeployAndUpgrade.ts --network hardhat
```

**输出示例**：

```
==================== 开始部署和升级 UpgradeableERC20 ====================

【第一步】部署 UpgradeableERC20 V1...
✅ UpgradeableERC20 V1 部署成功!
代理合约地址: 0x694e79...
V1 实现合约地址: 0x693967...

【第二步】升级到 UpgradeableERC20V2...
✅ 升级兼容性检查通过
✅ 合约升级成功!
✅ 状态保留验证成功!
✅ V2 初始化成功!

测试 V2 新增功能...
✅ getTokenInfo 测试成功!
✅ batchTransfer 测试成功!
✅ 最大供应量限制测试成功!

V2 新增功能:
  ✅ batchTransfer() - 批量转账
  ✅ getTokenInfo() - 获取代币信息
  ✅ maxSupply - 最大供应量限制
  ✅ initializeV2() - V2 状态初始化
```

**优点**:

- ✅ 完整演示升级流程
- ✅ 自动验证状态保留
- ✅ 测试所有新功能
- ✅ 适合开发和演示

### 方式二：分步部署（生产环境）

#### 第一步：部署 V1

```bash
# 启动本地节点（终端1，可选）
npx hardhat node --no-deploy

# 部署 V1（终端2）
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network localhost

# 或部署到测试网
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network sepolia
```

**输出**：

```
✅ UpgradeableERC20 代理合约部署成功!
代理合约地址: 0x694e79...
实现合约地址: 0x693967...

⚠️  请保存代理合约地址用于升级:
export UPGRADEABLE_ERC20_PROXY=0x694e79...
```

**重要**：保存代理合约地址！

#### 第二步：升级到 V2

```bash
# 设置代理地址
export UPGRADEABLE_ERC20_PROXY=0x694e79...

# 升级到 V2
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network localhost

# 或一行命令
UPGRADEABLE_ERC20_PROXY=0x694e79... npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network sepolia
```

**输出**：

```
✅ 升级兼容性检查通过
✅ 合约升级成功!
✅ 状态保留验证成功!
✅ V2 初始化成功!

V2 新增功能:
  ✅ batchTransfer() - 批量转账
  ✅ getTokenInfo() - 获取代币信息
  ✅ maxSupply - 最大供应量限制
```

## 部署参数

### V1 参数

```typescript
const name = "Upgradeable Token"; // 代币名称
const symbol = "UPG"; // 代币符号
const initialSupply = 1000000; // 初始供应量（不含小数位）
const owner = deployer.address; // 拥有者地址
```

### V2 参数

```typescript
const maxSupply = ethers.parseEther("10000000"); // 最大供应量：10,000,000 tokens
```

## 网络配置

### Hardhat Network（开发）

```bash
npx hardhat run deploy/upgradeable_erc20/DeployAndUpgrade.ts --network hardhat
```

**特点**:

- ✅ 快速
- ✅ 无需真实 ETH
- ✅ 可重置
- ❌ 临时性（每次运行重启）

### Localhost（本地持久化）

```bash
# 终端1
npx hardhat node --no-deploy

# 终端2
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network localhost
```

**特点**:

- ✅ 持久化
- ✅ 可分步操作
- ✅ 完整的区块链环境
- ⚠️ 需要启动节点

### Sepolia 测试网

```bash
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network sepolia
```

**特点**:

- ✅ 真实区块链
- ✅ 可验证合约
- ⚠️ 需要测试 ETH
- ⚠️ 交易需要时间

### 主网（生产环境）

```bash
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network mainnet
```

**重要提醒**:

- ⚠️ 确保已充分测试
- ⚠️ 确保已审计
- ⚠️ 使用多签钱包
- ⚠️ 准备应急方案

## 常见问题

### Q1: 如何查看已部署合约的实现地址？

```typescript
const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
console.log("实现地址:", implementationAddress);
```

### Q2: 升级失败怎么办？

1. 检查是否使用了正确的代理地址
2. 检查账户是否有 UPGRADER_ROLE
3. 运行兼容性检查：
   ```typescript
   await upgrades.validateUpgrade(proxyAddress, NewImplementation);
   ```

### Q3: 如何在升级后添加新状态？

使用 `reinitializer`：

```solidity
function initializeV2(uint256 newValue) public reinitializer(2) {
  newStateVariable = newValue;
}
```

### Q4: 组合脚本和分步脚本怎么选？

| 场景       | 推荐方式 |
| ---------- | -------- |
| 开发测试   | 组合脚本 |
| 演示说明   | 组合脚本 |
| 测试网部署 | 分步脚本 |
| 生产部署   | 分步脚本 |
| 未来升级   | 分步脚本 |

## 安全检查清单

### 部署前

- [ ] 已完成完整测试（55个测试全部通过）
- [ ] 已在测试网验证
- [ ] 代币参数正确（名称、符号、初始供应量）
- [ ] 拥有者地址正确
- [ ] Gas 价格合理

### 升级前

- [ ] 已运行 `validateUpgrade` 检查
- [ ] 状态布局兼容
- [ ] 已在测试网测试升级
- [ ] 确认代理地址正确
- [ ] 账户有 UPGRADER_ROLE
- [ ] 准备了回滚方案

### 升级后

- [ ] 验证状态保留
- [ ] 测试新功能
- [ ] 验证合约代码
- [ ] 更新文档
- [ ] 通知用户

## 相关资源

### 文档

- [UpgradeableERC20 合约文档](../../contracts/extensions/token/standard/UpgradeableERC20.md)
- [测试文档](../../test/upgradeable_erc20/README.md)
- [Demo 示例](../demo/)

### 工具

- [OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/)
- [Hardhat](https://hardhat.org/)

## 许可证

MIT License
