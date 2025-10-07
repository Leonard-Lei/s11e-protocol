# ERC20 代币合约文档

## 概述

这是一个高级的 ERC20 代币实现，扩展了 OpenZeppelin 的可升级合约，增加了访问控制、暂停功能、销毁、闪电铸造和 Conflux 特定功能等特性。

## 合约变体

### StandardERC20

一个简化的、不可升级的 ERC20 代币实现，适用于基本的代币操作。

**特性**：

- 基本 ERC20 功能（转账、授权、余额查询）
- 可销毁代币
- 基于所有者的访问控制（Ownable）
- 可铸造，具有最大供应量限制（10,000,000 代币）
- 批量转账功能
- ERC20Permit 支持无 Gas 授权
- 较低的部署成本

**使用场景**：

- 简单的代币部署
- 固定的治理代币
- 不需要升级的实用代币
- 节省 Gas 的基础代币

### UpgradeableERC20

一个高级的、可升级的 ERC20 代币，具有全面的功能和 Conflux 集成。

**特性**：

- 所有 StandardERC20 功能，以及：
- UUPS 可升级模式
- 基于角色的访问控制（多个角色）
- 可暂停转账
- 闪电铸造功能
- ERC1363 可支付代币支持
- Conflux 赞助控制用于 Gas 费用管理
- ETH/BNB 存款和提取

**使用场景**：

- 需要未来更新的长期代币项目
- 需要高级功能的 DeFi 协议
- Conflux 生态系统集成
- 企业级代币实现

### 对比表

| 功能             | StandardERC20         | UpgradeableERC20     |
| ---------------- | --------------------- | -------------------- |
| **可升级性**     | ❌ 否                 | ✅ UUPS 模式         |
| **访问控制**     | Ownable（单一所有者） | 基于角色（多个角色） |
| **可暂停**       | ❌ 否                 | ✅ 是                |
| **闪电铸造**     | ❌ 否                 | ✅ 是                |
| **ERC1363**      | ❌ 否                 | ✅ 是                |
| **ERC20Permit**  | ✅ 是                 | ✅ 是                |
| **可销毁**       | ✅ 是                 | ✅ 是                |
| **可铸造**       | ✅ 是（有最大供应量） | ✅ 是（无限制）      |
| **批量转账**     | ✅ 是                 | ❌ 否                |
| **Conflux 集成** | ❌ 否                 | ✅ 赞助控制          |
| **ETH 处理**     | ❌ 否                 | ✅ 存款/提取         |
| **部署成本**     | ~1.36M gas            | 更高（代理 + 实现）  |
| **复杂度**       | 低                    | 高                   |
| **最适合**       | 简单代币              | 企业/DeFi            |

## 合约特性（UpgradeableERC20）

### 核心特性

- **可升级**: 使用 UUPS（通用可升级代理标准）模式
- **访问控制**: 基于角色的权限系统
- **可暂停**: 可以暂停/恢复代币转账
- **可销毁**: 持有者可以销毁代币
- **闪电铸造**: 支持闪电贷
- **ERC1363**: 支持可支付代币标准
- **ERC20Permit**: 通过签名实现无 Gas 授权
- **Conflux 集成**: 用于 Gas 费用管理的赞助控制

### 继承的合约

- `Initializable` - 可升级合约的初始化模式
- `ERC20Upgradeable` - 基础 ERC20 功能
- `ERC20BurnableUpgradeable` - 代币销毁功能
- `ERC20PausableUpgradeable` - 暂停/恢复功能
- `AccessControlUpgradeable` - 基于角色的访问控制
- `ERC1363Upgradeable` - 可支付代币标准
- `ERC20PermitUpgradeable` - 无 Gas 授权
- `ERC20FlashMintUpgradeable` - 闪电贷功能
- `UUPSUpgradeable` - 升级机制

## 角色

### 角色常量

- `DEFAULT_ADMIN_ROLE` - 完全管理权限
- `PAUSER_ROLE` - 可以暂停/恢复合约
- `MINTER_ROLE` - 可以铸造新代币
- `UPGRADER_ROLE` - 可以升级合约

## 合约接口

### 初始化

```solidity
function initialize(
    string memory _name,
    string memory _symbol,
    uint256 _initialSupply,
    address _owner
) public initializer
```

**描述**: 使用代币详情初始化合约，并将角色分配给所有者和部署者。

**参数**:

- `_name`: 代币名称
- `_symbol`: 代币符号
- `_initialSupply`: 初始代币供应量
- `_owner`: 将获得管理角色的所有者地址

### 代币转账函数

#### 标准转账

```solidity
function transfer(address to, uint256 amount) public virtual returns (bool)
```

**描述**: 标准 ERC20 转账函数。

#### 带特权的增强转账

```solidity
function transfer(
    address _recipient,
    uint256 _amount,
    bool _addPrivilege
) public returns (bool)
```

**描述**: 扩展的转账函数，可以选择性地将接收者添加到特权列表中以获得 Gas 费用赞助。

**参数**:

- `_recipient`: 接收者地址
- `_amount`: 转账数量
- `_addPrivilege`: 是否将接收者添加到特权列表

### 管理函数

#### 暂停控制

```solidity
function pause() public onlyRole(PAUSER_ROLE)
function unpause() public onlyRole(PAUSER_ROLE)
```

**描述**: 暂停或恢复代币转账。

#### 铸造

```solidity
function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE)
```

**描述**: 向指定地址铸造新代币。

### Conflux 特定函数

#### 特权管理

```solidity
function addPrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE)
function removePrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE)
```

**描述**: 管理 Conflux 网络的 Gas 费用赞助特权。

**参数**:

- `_account`: 要添加/从特权列表中移除的地址数组
- 特殊情况: `["0x0000000000000000000000000000000000000000"]` 允许所有地址

### 升级函数

#### 合约升级

```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE)
```

**描述**: 授权合约升级（内部函数）。

### 财务函数

#### 提取

```solidity
function withdraw(uint256 _amount) external
```

**描述**: 从合约中提取 ETH/BNB。

**要求**:

- 调用者必须具有 `DEFAULT_ADMIN_ROLE`
- 金额不能超过合约余额

#### 余额查询

```solidity
function balance() public view returns (uint256)
```

**描述**: 返回合约的 ETH/BNB 余额。

### 事件处理

#### 接收函数

```solidity
receive() external payable virtual
```

**描述**: 允许合约接收 ETH/BNB 转账。

## 重写函数

### 更新函数

```solidity
function _update(
    address from,
    address to,
    uint256 value
) internal override(ERC20Upgradeable, ERC20PausableUpgradeable)
```

**描述**: 重写更新函数以处理 ERC20 和可暂停功能。

### 接口支持

```solidity
function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable, ERC1363Upgradeable) returns (bool)
```

**描述**: 返回合约是否支持指定的接口。

## 安全特性

### 访问控制

- 所有管理功能的基于角色的权限
- 不同访问级别的多个角色
- 所有者和部署者在初始化时都获得管理角色

### 升级安全

- 用于安全升级的 UUPS 模式
- 只有 `UPGRADER_ROLE` 可以授权升级
- 构造函数禁用初始化器以确保安全

### 可暂停性

- 紧急暂停功能
- 只有 `PAUSER_ROLE` 可以暂停/恢复
- 暂停时影响所有代币转账

## Gas 优化

### Conflux 集成

- Gas 费用管理的赞助控制
- 减少用户交易成本的特权系统
- 用于 Gas 费用处理的可支付函数

## 使用示例

### 基础代币操作

```solidity
// 初始化代币
erc20.initialize("MyToken", "MTK", 1000000, owner);

// 带特权的转账: the recipient will be added to the privilege list
erc20.transfer(recipient, 1000, true);

// 铸造新代币
erc20.mint(user, 5000);
```

### 管理操作

```solidity
// 暂停转账
erc20.pause();

// 添加 Gas 费用特权
address[] memory privileged = new address[](1);
privileged[0] = userAddress;
erc20.addPrivilege(privileged);
```

## 网络兼容性

- **以太坊**: 完整功能
- **Conflux**: 增强的 Gas 费用管理赞助控制
- **其他 EVM 兼容链**: 标准 ERC20 功能

## 部署和测试

### 前置条件

- 已安装 Node.js 和 npm
- 已配置 Hardhat
- 拥有用于部署的私钥或助记词
- 拥有足够的 ETH/CFX 用于支付 Gas 费用

### 部署步骤

#### 1. 部署 ERC20 代币

```bash
# 部署到本地网络
npx hardhat run scripts/deploy-erc20.js --network hardhat

# 部署到测试网
npx hardhat run scripts/deploy-erc20.js --network goerli

# 部署到主网
npx hardhat run scripts/deploy-erc20.js --network mainnet
```

#### 2. 环境变量

在 `.env` 文件中设置以下环境变量：

```bash
OWNER_ADDRESS=0x...  # 将获得管理角色的地址
ETH_NODE_URL=https://...  # 网络的 RPC URL
WALLET_MNEMONIC="your mnemonic phrase"
```

#### 3. 部署脚本功能

部署脚本 (`scripts/deploy-erc20.js`) 包含：

- 使用 UUPS 模式自动代理部署
- 向所有者和部署者分配角色
- 代币信息验证
- 实现和管理地址记录

### 测试

#### 1. StandardERC20 测试

StandardERC20 合约是一个简化的、不可升级的版本，用于基本代币功能测试。

```bash
# 运行 StandardERC20 测试
npx hardhat test test/standard_erc20/StandardERC20.ts

# 运行带 Gas 报告的测试
REPORT_GAS=true npx hardhat test test/standard_erc20/StandardERC20.ts
```

**测试覆盖范围（39 个测试）**：

- **部署 (6 个测试)**: 代币名称、符号、小数位、拥有者、最大供应量、初始供应量
- **getTokenInfo (1 个测试)**: 代币信息检索
- **铸造 (6 个测试)**: 拥有者铸造、供应量管理、最大供应量限制、权限检查
- **转账 (4 个测试)**: 基本转账、余额更新、余额不足检查、事件
- **批量转账 (5 个测试)**: 批量操作、权限、数组验证、余额检查
- **授权 (5 个测试)**: Approve/transferFrom、授权额度管理、事件
- **销毁 (5 个测试)**: Burn 和 burnFrom、供应量减少、授权额度消耗
- **Permit/EIP-2612 (2 个测试)**: DOMAIN_SEPARATOR、nonces
- **所有权 (5 个测试)**: 转移所有权、放弃所有权、权限变更

**Gas 使用量**：

- 部署: ~1,360,898 gas
- 铸造: ~70,887 gas
- 转账: ~51,603 gas
- 批量转账: 80,867 - 106,593 gas
- 销毁: ~33,881 gas
- 授权: ~46,401 gas

#### 2. UpgradeableERC20 测试

```bash
# 运行所有可升级 ERC20 测试
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts

# 运行带 Gas 报告的测试
REPORT_GAS=true npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts

# 运行特定测试
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts --grep "Upgrade"
```

#### 3. 综合测试脚本

```bash
# 运行综合测试套件
npx hardhat run scripts/test-standard-erc20.js --network hardhat
```

#### 4. 测试覆盖范围

可升级版本测试套件涵盖：

- **部署测试**: 名称、符号、小数位、总供应量、角色分配
- **基础 ERC20 功能**: 转账、授权、transferFrom、allowance
- **增强功能**: 特权转账、暂停/恢复、铸造、销毁
- **Conflux 集成**: 特权管理、赞助控制
- **财务功能**: ETH 存款、提取
- **高级功能**: ERC1363、ERC20Permit、闪电铸造
- **升级功能**: UUPS 可升级性验证
- **接口支持**: ERC20、ERC1363、AccessControl 接口

### 升级流程

#### 1. 准备新实现

```solidity
// 创建具有附加功能的新合约
contract ERC20V2 is ERC20 {
  // 添加新功能
  function newFeature() public {
    // 实现
  }
}
```

#### 2. 部署升级

```bash
# 升级现有代理
npx hardhat run scripts/upgrade-standard-erc20.js --network mainnet

# 使用特定代理地址
npx hardhat run scripts/upgrade-standard-erc20.js --network mainnet -- 0x1234...
```

#### 3. 验证升级

```bash
# 验证实现已更改
npx hardhat run scripts/verify-upgrade.js --network mainnet
```

### 网络特定配置

#### 以太坊网络

```javascript
// hardhat.config.js
module.exports = {
  networks: {
    mainnet: {
      url: process.env.ETH_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    goerli: {
      url: process.env.GOERLI_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
```

#### Conflux 网络

```javascript
// 对于 Conflux，需要额外配置
module.exports = {
  networks: {
    conflux: {
      url: process.env.CONFLUX_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1029,
    },
  },
};
```

### 安全考虑

#### 1. 角色管理

- 确保只有受信任的地址具有管理角色
- 在生产部署中使用多签钱包
- 定期审计角色分配

#### 2. 升级安全

- 先在测试网上测试升级
- 验证升级后状态保持
- 准备回滚计划

#### 3. Gas 优化

- 为不同网络使用适当的 Gas 限制
- 考虑 Conflux 的 Gas 价格优化
- 监控生产中的 Gas 使用

### 故障排除

#### 常见问题

1. **部署失败**: 检查网络配置和 Gas 限制
2. **角色分配失败**: 验证所有者地址和权限
3. **升级失败**: 确保新实现兼容
4. **测试失败**: 检查网络连接和账户余额

#### 调试命令

```bash
# 检查合约状态
npx hardhat console --network mainnet
> const contract = await ethers.getContractAt("ERC20", "0x...")
> await contract.name()

# 验证实现
npx hardhat verify --network mainnet 0x... "constructor args"
```

## 许可证

MIT 许可证 - 兼容 OpenZeppelin Contracts ^5.4.0
