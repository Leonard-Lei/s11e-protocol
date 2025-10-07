# StandardERC20 代币合约文档

## 概述

StandardERC20 是一个简化的、不可升级的 ERC20 代币实现，基于 OpenZeppelin Contracts
v5.4.0，提供基本的代币功能和额外的批量转账特性。适用于不需要复杂功能和升级机制的代币项目。

## 合约特性

### 核心特性

- **基础 ERC20**: 标准的 ERC20 代币功能（转账、授权、余额查询）
- **可销毁**: 代币持有者可以销毁自己的代币
- **可铸造**: 拥有者可以铸造新代币，但有最大供应量限制
- **批量转账**: 拥有者可以一次性向多个地址转账
- **ERC20Permit**: 支持通过签名进行无 Gas 授权（EIP-2612）
- **访问控制**: 基于 Ownable 的简单所有者权限管理

### 继承的合约

- `ERC20` - 基础 ERC20 功能
- `ERC20Burnable` - 代币销毁功能
- `Ownable` - 所有者权限控制
- `ERC20Permit` - 无 Gas 授权功能

## 合约参数

### 常量

- `MAX_SUPPLY`: 最大供应量 = 10,000,000 代币（10^7 \* 10^18）

### 构造函数参数

```solidity
constructor(
    string memory _name,      // 代币名称
    string memory _symbol,    // 代币符号
    uint256 _initialSupply,   // 初始供应量（当前版本未使用）
    address _owner            // 代币拥有者地址
)
```

## 合约接口

### 代币信息查询

#### getTokenInfo

```solidity
function getTokenInfo() external view returns (
    string memory name,
    string memory symbol,
    uint8 decimals,
    uint256 totalSupply,
    uint256 maxSupply
)
```

**描述**: 获取代币的完整信息。

**返回值**:

- `name`: 代币名称
- `symbol`: 代币符号
- `decimals`: 小数位数（18）
- `totalSupply`: 当前总供应量
- `maxSupply`: 最大供应量

**示例**:

```solidity
(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, uint256 maxSupply) = token.getTokenInfo();
```

### 铸造功能

#### mint

```solidity
function mint(address to, uint256 amount) public onlyOwner
```

**描述**: 向指定地址铸造新代币。

**权限**: 仅拥有者

**参数**:

- `to`: 接收代币的地址
- `amount`: 铸造的代币数量

**限制**:

- 铸造后的总供应量不能超过 `MAX_SUPPLY`

**示例**:

```solidity
token.mint(userAddress, 1000 * 10**18); // 铸造 1000 个代币
```

### 转账功能

#### transfer

```solidity
function transfer(address to, uint256 amount) public virtual returns (bool)
```

**描述**: 标准 ERC20 转账功能。

**参数**:

- `to`: 接收地址
- `amount`: 转账数量

#### batchTransfer

```solidity
function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata amounts
) external onlyOwner
```

**描述**: 批量转账功能，可以一次性向多个地址转账。

**权限**: 仅拥有者

**参数**:

- `recipients`: 接收地址数组
- `amounts`: 对应的转账数量数组

**要求**:

- 两个数组长度必须相同
- 拥有者必须有足够的余额

**示例**:

```solidity
address[] memory recipients = new address[](3);
recipients[0] = address1;
recipients[1] = address2;
recipients[2] = address3;

uint256[] memory amounts = new uint256[](3);
amounts[0] = 100 * 10**18;
amounts[1] = 200 * 10**18;
amounts[2] = 300 * 10**18;

token.batchTransfer(recipients, amounts);
```

### 销毁功能

#### burn

```solidity
function burn(uint256 amount) public virtual
```

**描述**: 销毁调用者的代币。

**参数**:

- `amount`: 要销毁的代币数量

#### burnFrom

```solidity
function burnFrom(address account, uint256 amount) public virtual
```

**描述**: 销毁授权给自己的代币。

**参数**:

- `account`: 代币持有者地址
- `amount`: 要销毁的代币数量

**要求**:

- 调用者必须有足够的授权额度

### 授权功能

#### approve

```solidity
function approve(address spender, uint256 amount) public virtual returns (bool)
```

**描述**: 授权指定地址使用自己的代币。

**参数**:

- `spender`: 被授权的地址
- `amount`: 授权数量

#### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) public virtual returns (bool)
```

**描述**: 从授权地址转账代币。

**参数**:

- `from`: 代币来源地址
- `to`: 接收地址
- `amount`: 转账数量

#### allowance

```solidity
function allowance(address owner, address spender) public view virtual returns (uint256)
```

**描述**: 查询授权额度。

### ERC20Permit 功能

#### permit

```solidity
function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public virtual
```

**描述**: 通过签名进行授权，无需消耗 gas。

#### nonces

```solidity
function nonces(address owner) public view virtual returns (uint256)
```

**描述**: 查询地址的当前 nonce 值。

#### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32)
```

**描述**: 返回 EIP-712 域分隔符。

### 所有权管理

#### transferOwnership

```solidity
function transferOwnership(address newOwner) public virtual onlyOwner
```

**描述**: 转移合约所有权。

**权限**: 仅拥有者

#### renounceOwnership

```solidity
function renounceOwnership() public virtual onlyOwner
```

**描述**: 放弃合约所有权（将所有权转移到零地址）。

**权限**: 仅拥有者

#### owner

```solidity
function owner() public view virtual returns (address)
```

**描述**: 查询当前合约拥有者。

## 使用示例

### 部署合约

```solidity
// 部署 StandardERC20
StandardERC20 token = new StandardERC20(
    "My Token",           // 代币名称
    "MTK",               // 代币符号
    1000000,             // 初始供应量（当前未使用）
    msg.sender           // 拥有者地址
);
```

### 基本操作

```solidity
// 铸造代币
token.mint(userAddress, 1000 * 10**18);

// 转账
token.transfer(recipient, 100 * 10**18);

// 授权
token.approve(spender, 500 * 10**18);

// 授权转账
token.transferFrom(owner, recipient, 200 * 10**18);

// 销毁代币
token.burn(50 * 10**18);

// 批量转账
address[] memory recipients = new address[](2);
recipients[0] = user1;
recipients[1] = user2;

uint256[] memory amounts = new uint256[](2);
amounts[0] = 100 * 10**18;
amounts[1] = 200 * 10**18;

token.batchTransfer(recipients, amounts);
```

### 查询信息

```solidity
// 获取代币信息
(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, uint256 maxSupply) = token.getTokenInfo();

// 查询余额
uint256 balance = token.balanceOf(userAddress);

// 查询授权额度
uint256 allowance = token.allowance(owner, spender);

// 查询总供应量
uint256 totalSupply = token.totalSupply();

// 查询最大供应量
uint256 maxSupply = token.MAX_SUPPLY();
```

## 部署和测试

### 环境要求

- Node.js >= 16.0.0
- Hardhat
- OpenZeppelin Contracts ^5.4.0

### 部署步骤

#### 1. 安装依赖

```bash
npm install
```

#### 2. 编译合约

```bash
npx hardhat compile
```

#### 3. 部署到本地网络

```bash
npx hardhat run scripts/deploy-standard-erc20.js --network hardhat
```

#### 4. 部署到测试网

```bash
npx hardhat run scripts/deploy-standard-erc20.js --network sepolia
```

### 测试

#### 运行测试

```bash
# 运行所有测试
npx hardhat test test/standard_erc20/StandardERC20.ts

# 运行带 Gas 报告的测试
REPORT_GAS=true npx hardhat test test/standard_erc20/StandardERC20.ts
```

#### 测试覆盖范围

测试套件包含 **39 个测试用例**，覆盖以下功能：

##### 1. 部署测试 (6 个)

- ✅ 应该设置正确的代币名称
- ✅ 应该设置正确的代币符号
- ✅ 应该设置正确的小数位数
- ✅ 应该设置正确的拥有者
- ✅ 应该正确设置最大供应量
- ✅ 初始总供应量应该为 0

##### 2. getTokenInfo 测试 (1 个)

- ✅ 应该返回正确的代币信息

##### 3. 铸造功能测试 (6 个)

- ✅ 拥有者应该能够铸造代币
- ✅ 铸造应该增加总供应量
- ✅ 非拥有者不应该能够铸造代币
- ✅ 不应该允许铸造超过最大供应量
- ✅ 应该能够铸造到最大供应量
- ✅ 铸造到最大供应量后不能再铸造

##### 4. 转账功能测试 (4 个)

- ✅ 应该能够转账代币
- ✅ 转账应该减少发送者余额
- ✅ 不应该允许转账超过余额的代币
- ✅ 应该触发 Transfer 事件

##### 5. 批量转账测试 (5 个)

- ✅ 拥有者应该能够批量转账
- ✅ 批量转账应该减少拥有者余额
- ✅ 非拥有者不应该能够批量转账
- ✅ 数组长度不匹配应该失败
- ✅ 余额不足时批量转账应该失败

##### 6. 授权功能测试 (5 个)

- ✅ 应该能够授权代币
- ✅ 应该触发 Approval 事件
- ✅ 被授权者应该能够使用 transferFrom
- ✅ transferFrom 应该减少授权额度
- ✅ 不应该允许超过授权额度的 transferFrom

##### 7. 销毁功能测试 (5 个)

- ✅ 持有者应该能够销毁自己的代币
- ✅ 销毁应该减少总供应量
- ✅ 不应该允许销毁超过余额的代币
- ✅ 应该能够使用 burnFrom 销毁授权的代币
- ✅ burnFrom 应该减少授权额度

##### 8. Permit/EIP-2612 测试 (2 个)

- ✅ 应该有正确的 domain separator
- ✅ 应该有正确的 nonces

##### 9. 所有权管理测试 (5 个)

- ✅ 应该能够转移所有权
- ✅ 转移所有权后原拥有者不应该能够铸造
- ✅ 新拥有者应该能够铸造
- ✅ 应该能够放弃所有权
- ✅ 非拥有者不应该能够转移所有权

#### 测试结果

```
StandardERC20
  部署
    ✔ 应该设置正确的代币名称
    ✔ 应该设置正确的代币符号
    ✔ 应该设置正确的小数位数
    ✔ 应该设置正确的拥有者
    ✔ 应该正确设置最大供应量
    ✔ 初始总供应量应该为0
  getTokenInfo
    ✔ 应该返回正确的代币信息
  铸造 (Mint)
    ✔ 拥有者应该能够铸造代币
    ✔ 铸造应该增加总供应量
    ✔ 非拥有者不应该能够铸造代币
    ✔ 不应该允许铸造超过最大供应量
    ✔ 应该能够铸造到最大供应量
    ✔ 铸造到最大供应量后不能再铸造
  转账 (Transfer)
    ✔ 应该能够转账代币
    ✔ 转账应该减少发送者余额
    ✔ 不应该允许转账超过余额的代币
    ✔ 应该触发 Transfer 事件
  批量转账 (BatchTransfer)
    ✔ 拥有者应该能够批量转账
    ✔ 批量转账应该减少拥有者余额
    ✔ 非拥有者不应该能够批量转账
    ✔ 数组长度不匹配应该失败
    ✔ 余额不足时批量转账应该失败
  授权 (Allowance)
    ✔ 应该能够授权代币
    ✔ 应该触发 Approval 事件
    ✔ 被授权者应该能够使用 transferFrom
    ✔ transferFrom 应该减少授权额度
    ✔ 不应该允许超过授权额度的 transferFrom
  销毁 (Burn)
    ✔ 持有者应该能够销毁自己的代币
    ✔ 销毁应该减少总供应量
    ✔ 不应该允许销毁超过余额的代币
    ✔ 应该能够使用 burnFrom 销毁授权的代币
    ✔ burnFrom 应该减少授权额度
  Permit (EIP-2612)
    ✔ 应该有正确的 domain separator
    ✔ 应该有正确的 nonces
  所有权 (Ownable)
    ✔ 应该能够转移所有权
    ✔ 转移所有权后原拥有者不应该能够铸造
    ✔ 新拥有者应该能够铸造
    ✔ 应该能够放弃所有权
    ✔ 非拥有者不应该能够转移所有权

39 passing (16s)
```

### Gas 使用统计

| 操作                               | Gas 消耗 (Min) | Gas 消耗 (Max) | Gas 消耗 (Avg) | 调用次数 |
| ---------------------------------- | -------------- | -------------- | -------------- | -------- |
| **部署**                           | -              | -              | 1,360,898      | -        |
| **铸造 (mint)**                    | 70,877         | 70,889         | 70,887         | 28       |
| **转账 (transfer)**                | -              | -              | 51,603         | 5        |
| **批量转账 (batchTransfer)**       | 80,867         | 106,593        | 98,018         | 3        |
| **销毁 (burn)**                    | -              | -              | 33,881         | 3        |
| **授权销毁 (burnFrom)**            | 35,059         | 39,859         | 36,659         | 3        |
| **授权 (approve)**                 | -              | -              | 46,401         | 9        |
| **授权转账 (transferFrom)**        | 52,892         | 57,692         | 54,492         | 3        |
| **转移所有权 (transferOwnership)** | -              | -              | 28,697         | 4        |
| **放弃所有权 (renounceOwnership)** | -              | -              | 23,335         | 2        |

**部署成本分析**:

- 部署大小: 5.496 KiB
- 初始化代码: 6.790 KiB
- 主网限制占比: ~4.5%

## 与 UpgradeableERC20 对比

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

## 安全考虑

### 1. 最大供应量限制

- 合约设置了 10,000,000 代币的硬顶
- 任何铸造操作都会检查是否超过最大供应量
- 防止通货膨胀和供应量失控

### 2. 所有权管理

- 只有拥有者可以铸造代币和执行批量转账
- 可以转移所有权给新地址
- 可以放弃所有权（不可逆操作）

### 3. 销毁机制

- 持有者可以销毁自己的代币
- 可以销毁授权给自己的代币
- 销毁会永久减少总供应量

### 4. 批量转账风险

- 只有拥有者可以执行批量转账
- 数组长度必须匹配
- 需要足够的余额

### 5. 建议

- 在生产环境使用多签钱包作为拥有者
- 部署后验证合约代码
- 进行充分的审计
- 谨慎使用 `renounceOwnership`

## 适用场景

### 适合使用 StandardERC20

- ✅ 简单的代币发行
- ✅ 固定的治理代币
- ✅ 不需要升级的实用代币
- ✅ 需要批量发放奖励的项目
- ✅ Gas 成本敏感的项目
- ✅ 快速部署的 MVP 项目

### 不适合使用 StandardERC20

- ❌ 需要频繁更新功能
- ❌ 需要暂停功能的场景
- ❌ 需要复杂权限管理
- ❌ 需要闪电贷功能
- ❌ Conflux 生态项目
- ❌ 需要接收 ETH 的代币

## 常见问题

### 1. 为什么初始供应量参数没有使用？

当前版本的构造函数接受 `_initialSupply` 参数但未使用。代币需要在部署后通过 `mint`
函数铸造。这样可以更灵活地控制代币分发。

### 2. 如何修改最大供应量？

`MAX_SUPPLY` 是常量，部署后无法修改。如果需要修改，需要重新部署合约。

### 3. 批量转账有数量限制吗？

批量转账的数量受 gas 限制约束。建议单次批量转账不超过 100-200 个地址。

### 4. 可以恢复已销毁的代币吗？

不可以。销毁的代币会永久从流通中移除，无法恢复。

### 5. 如何升级合约？

StandardERC20 不支持升级。如需升级功能，请使用 UpgradeableERC20。

## 技术规范

- **Solidity 版本**: >= 0.8.20
- **OpenZeppelin 版本**: ^5.4.0
- **EVM 版本**: Cancun
- **许可证**: MIT

## 相关资源

### 文档

- [UpgradeableERC20 文档](./UpgradeableERC20.md)
- [UpgradeableERC20 中文文档](./UpgradeableERC20-Zh.md)
- [测试文档](../../../test/standard_erc20/README.md)

### 代码

- [StandardERC20 合约](./StandardERC20.sol)
- [测试套件](../../../test/standard_erc20/StandardERC20.ts)
- [测试夹具](../../../test/standard_erc20/StandardERC20.fixture.ts)

### 外部资源

- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [EIP-20: Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [EIP-2612: Permit Extension](https://eips.ethereum.org/EIPS/eip-2612)

## 许可证

MIT License - 兼容 OpenZeppelin Contracts ^5.4.0
