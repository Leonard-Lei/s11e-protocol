# UpgradeableERC20 可升级代币测试套件

## 概述

完整的 UpgradeableERC20 可升级 ERC20 代币测试套件，演示企业级代币的部署、升级和功能验证。

## 文件结构

```
test/upgradeable_erc20/
├── UpgradeableERC20.fixture.ts    # 测试夹具
├── UpgradeableERC20.ts            # V1 测试（35个测试）
├── UpgradeableERC20V2.ts          # V2 测试（20个测试）
└── README.md                      # 本文档
```

## 快速开始

### 运行测试

```bash
# 运行 V1 测试
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts

# 运行 V2 测试
npx hardhat test test/upgradeable_erc20/UpgradeableERC20V2.ts

# 运行所有测试
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts test/upgradeable_erc20/UpgradeableERC20V2.ts

# 带 Gas 报告
REPORT_GAS=true npx hardhat test test/upgradeable_erc20/
```

### 部署

```bash
# 一次性部署和升级（推荐）
npx hardhat run deploy/upgradeable_erc20/DeployAndUpgrade.ts --network hardhat

# 分步部署
npx hardhat node --no-deploy  # 终端1
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network localhost  # 终端2
UPGRADEABLE_ERC20_PROXY=0x... npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network localhost
```

## 测试覆盖

### UpgradeableERC20 V1 测试（35个）

#### 1. 部署测试（7个）

- ✅ 应该设置正确的代币名称
- ✅ 应该设置正确的代币符号
- ✅ 应该设置正确的小数位数
- ✅ 应该正确初始化供应量
- ✅ 拥有者应该收到初始供应量
- ✅ 应该正确部署代理合约
- ✅ 不应该允许重复初始化

#### 2. 角色管理测试（6个）

- ✅ 拥有者应该有 DEFAULT_ADMIN_ROLE
- ✅ 拥有者应该有 MINTER_ROLE
- ✅ 拥有者应该有 PAUSER_ROLE
- ✅ 拥有者应该有 UPGRADER_ROLE
- ✅ 应该能够授予角色
- ✅ 应该能够撤销角色

#### 3. 铸造功能测试（3个）

- ✅ 有 MINTER_ROLE 的地址应该能够铸造
- ✅ 铸造应该增加总供应量
- ✅ 没有 MINTER_ROLE 的地址不应该能够铸造

#### 4. 暂停功能测试（5个）

- ✅ 有 PAUSER_ROLE 的地址应该能够暂停
- ✅ 有 PAUSER_ROLE 的地址应该能够恢复
- ✅ 暂停时不应该能够转账
- ✅ 恢复后应该能够转账
- ✅ 没有 PAUSER_ROLE 的地址不应该能够暂停

#### 5. 转账功能测试（2个）

- ✅ 应该能够转账代币
- ✅ 应该触发 Transfer 事件

#### 6. 销毁功能测试（2个）

- ✅ 持有者应该能够销毁代币
- ✅ 销毁应该减少总供应量

#### 7. 可升级性测试（5个）

- ✅ 应该能够升级到 V2
- ✅ 升级后应该保留余额
- ✅ 升级后应该保留总供应量
- ✅ 升级后应该有新功能
- ✅ 非 UPGRADER_ROLE 不应该能够升级

#### 8. 财务功能测试（5个）

- ✅ 合约应该能够接收 ETH
- ✅ 应该能够查询合约余额
- ✅ 管理员应该能够提取 ETH
- ✅ 非管理员不应该能够提取 ETH
- ✅ 不应该允许提取超过合约余额的 ETH

### UpgradeableERC20V2 测试（20个）

#### 1. 升级后的部署测试（6个）

- ✅ 应该保留代币名称
- ✅ 应该保留代币符号
- ✅ 应该保留总供应量
- ✅ 应该保留拥有者余额
- ✅ 代理地址应该保持不变
- ✅ 应该正确设置最大供应量

#### 2. 继承的功能测试（3个）

- ✅ 应该能够转账
- ✅ 应该能够暂停
- ✅ 应该能够销毁

#### 3. V2 新增：最大供应量限制（3个）

- ✅ 应该能够查询最大供应量
- ✅ 铸造不应该超过最大供应量
- ✅ 应该能够铸造到最大供应量

#### 4. V2 新增：批量转账功能（5个）

- ✅ 管理员应该能够批量转账
- ✅ 批量转账应该减少发送者余额
- ✅ 非管理员不应该能够批量转账
- ✅ 数组长度不匹配应该失败
- ✅ 余额不足时批量转账应该失败

#### 5. V2 新增：getTokenInfo 功能（1个）

- ✅ 应该返回正确的代币信息

#### 6. 状态保留测试（2个）

- ✅ 升级前的供应量应该在升级后保留
- ✅ 升级后的操作应该正常

## Gas 使用统计

| 合约/操作               | Gas 消耗         | 说明                      |
| ----------------------- | ---------------- | ------------------------- |
| **部署**                |
| UpgradeableERC20 部署   | 2,778,093        | V1 实现合约（9.3% 限制）  |
| UpgradeableERC20V2 部署 | 3,116,520        | V2 实现合约（10.4% 限制） |
| **操作**                |
| upgradeToAndCall        | ~38,034          | 升级合约                  |
| initializeV2            | ~55,326          | V2 初始化                 |
| batchTransfer           | 88,439 - 114,328 | 批量转账                  |
| mint                    | ~63,529          | 铸造代币                  |
| burn                    | ~41,135          | 销毁代币                  |
| pause                   | ~52,073          | 暂停合约                  |
| transfer                | ~58,837          | 转账                      |

## V1 vs V2 功能对比

| 功能               | V1  | V2  |
| ------------------ | --- | --- |
| 基础 ERC20         | ✅  | ✅  |
| 可销毁             | ✅  | ✅  |
| 可暂停             | ✅  | ✅  |
| 角色控制           | ✅  | ✅  |
| Flash Mint         | ✅  | ✅  |
| ERC1363            | ✅  | ✅  |
| ERC20Permit        | ✅  | ✅  |
| UUPS 升级          | ✅  | ✅  |
| Conflux 集成       | ✅  | ✅  |
| ETH 处理           | ✅  | ✅  |
| **最大供应量限制** | ❌  | ✅  |
| **批量转账**       | ❌  | ✅  |
| **getTokenInfo**   | ❌  | ✅  |
| **铸造限制检查**   | ❌  | ✅  |

## V2 新增功能详解

### 1. 最大供应量限制

```solidity
uint256 public maxSupply;

function initializeV2(uint256 _maxSupply) public reinitializer(2) {
    maxSupply = _maxSupply;
}

function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    if (maxSupply > 0) {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
    }
    _mint(to, amount);
}
```

**作用**:

- 限制代币总供应量
- 防止无限铸造
- 增加代币稀缺性

### 2. 批量转账

```solidity
function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata amounts
) external onlyRole(DEFAULT_ADMIN_ROLE)
```

**作用**:

- 一次转账到多个地址
- 节省 gas（相比多次单独转账）
- 适合空投和批量发放

### 3. 获取代币信息

```solidity
function getTokenInfo() external view returns (
    string memory name,
    string memory symbol,
    uint8 decimals,
    uint256 totalSupply,
    uint256 maxSupply_
)
```

**作用**:

- 一次调用获取所有关键信息
- 方便前端集成
- 减少 RPC 调用次数

## 测试策略

### 测试夹具设计

**deployUpgradeableERC20Fixture**:

- 部署 V1 代理合约
- 使用 UUPS 模式
- 初始化角色和供应量

**deployUpgradeableERC20V2Fixture**:

- 部署 V1
- 升级到 V2
- 初始化 V2 新状态（maxSupply）
- 完整模拟升级流程

### 测试重点

1. **状态保留**: 升级后所有状态（余额、供应量）必须保持不变
2. **角色系统**: 验证多角色权限控制
3. **新功能**: 确保 V2 新功能正常工作
4. **向后兼容**: V1 的所有功能在 V2 中仍然可用
5. **边界条件**: 测试最大供应量、数组长度等边界

## 部署建议

### 开发环境

```bash
# 使用组合脚本（推荐）
npx hardhat run deploy/upgradeable_erc20/DeployAndUpgrade.ts --network hardhat
```

### 测试网

```bash
# 终端1：启动节点
npx hardhat node --no-deploy

# 终端2：部署 V1
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network localhost

# 终端2：升级到 V2（使用上面输出的代理地址）
UPGRADEABLE_ERC20_PROXY=0x... npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network localhost
```

### 生产环境

```bash
# 部署 V1 到主网
npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20.ts --network mainnet

# 升级到 V2（谨慎！）
UPGRADEABLE_ERC20_PROXY=0x... npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network mainnet
```

## 升级注意事项

### ✅ 安全的升级

1. **保持存储布局**:
   - V2 保留了 V1 的所有状态变量
   - 新变量 `maxSupply` 添加在末尾
2. **使用 reinitializer**:
   ```solidity
   function initializeV2(uint256 _maxSupply) public reinitializer(2)
   ```
3. **升级前验证**:

   ```typescript
   await upgrades.validateUpgrade(proxyAddress, UpgradeableERC20V2);
   ```

4. **测试网验证**:
   - 先在测试网完整测试
   - 验证所有功能正常
   - 确认状态正确保留

### ❌ 危险操作

- ❌ 不要修改现有状态变量的顺序
- ❌ 不要删除现有状态变量
- ❌ 不要修改现有状态变量的类型
- ❌ 不要在生产环境跳过兼容性检查

## 相关文档

- [UpgradeableERC20 完整文档](../../contracts/extensions/token/standard/UpgradeableERC20.md)
- [UpgradeableERC20 中文文档](../../contracts/extensions/token/standard/UpgradeableERC20-Zh.md)
- [Demo 可升级示例](../demo/)

## 许可证

MIT License
