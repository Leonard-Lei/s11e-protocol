# Demo 可升级合约测试套件

## 概述

完整的 Demo 可升级合约测试套件，演示如何使用 `@openzeppelin/hardhat-upgrades` 进行合约升级。

## 文件结构

```
test/demo/
├── Demo.fixture.ts    # 测试夹具（包含 deployDemoFixture 和 deployDemoV2Fixture）
├── Demo.ts            # Demo V1 测试（12个测试）
├── DemoV2.ts          # DemoV2 测试（12个测试）
└── README.md          # 本文档
```

## 快速开始

### 运行所有测试

```bash
# 运行 Demo V1 测试
npx hardhat test test/demo/Demo.ts

# 运行 DemoV2 测试
npx hardhat test test/demo/DemoV2.ts

# 运行所有测试
npx hardhat test test/demo/Demo.ts test/demo/DemoV2.ts

# 带 Gas 报告
REPORT_GAS=true npx hardhat test test/demo/Demo.ts test/demo/DemoV2.ts
```

## 测试覆盖

### Demo V1 测试（12个）

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

### DemoV2 测试（12个）

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

## Gas 使用统计

| 合约/操作   | Gas 消耗 | 说明        |
| ----------- | -------- | ----------- |
| Demo 部署   | 158,399  | V1 实现合约 |
| DemoV2 部署 | 188,863  | V2 实现合约 |
| store       | ~32,442  | 存储值      |
| increment   | ~32,313  | 递增值      |

## 测试夹具说明

### deployDemoFixture

部署 Demo V1 代理合约：

```typescript
const { demo, demoAddress, initialValue, owner, addr1, addr2 } = await loadFixture(deployDemoFixture);
```

**返回值**:

- `demo`: Demo 合约实例
- `demoAddress`: 代理合约地址
- `initialValue`: 初始值（42）
- `owner`, `addr1`, `addr2`: 测试账户

### deployDemoV2Fixture

部署 Demo V1 并升级到 DemoV2：

```typescript
const { demo, demoAddress, initialValue, owner, addr1, addr2 } = await loadFixture(deployDemoV2Fixture);
```

**注意**: `demo` 实例已经是 DemoV2 类型，包含 `increment()` 方法。

## 测试要点

### 1. 初始化测试

- ✅ 验证初始值正确设置
- ✅ 验证不能重复初始化（防止攻击）
- ✅ 验证代理合约正确部署

### 2. 基本功能测试

- ✅ store 功能正常
- ✅ retrieve 功能正常
- ✅ 事件正确触发
- ✅ 任何地址都可以操作（无权限限制）

### 3. 升级测试

- ✅ 能够成功升级到 DemoV2
- ✅ 升级后代理地址不变
- ✅ 升级后状态保留
- ✅ 升级后可以使用新功能

### 4. V2 新功能测试

- ✅ increment 功能正常
- ✅ increment 触发事件
- ✅ 可以多次 increment
- ✅ increment 和 store 配合使用

## 相关文档

- [Demo 合约完整指南](../../../contracts/test/Demo.md)
- [可升级合约指南](../../../doc/UpgradwableContract.md)

## 许可证

MIT License
