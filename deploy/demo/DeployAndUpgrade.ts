import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("==================== 开始部署和升级 Demo ====================\n");

  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // ==================== 第一步：部署 Demo V1 ====================
  console.log("【第一步】部署 Demo V1...\n");

  const initialValue = 42;
  console.log("初始值:", initialValue);

  const Demo = await ethers.getContractFactory("Demo");
  console.log("正在部署 Demo 代理合约...");

  const demo = await upgrades.deployProxy(Demo, [initialValue], {
    initializer: "initialize",
    kind: "transparent",
  });

  await demo.waitForDeployment();

  const proxyAddress = await demo.getAddress();
  console.log("\n✅ Demo V1 代理合约部署成功!");
  console.log("代理合约地址:", proxyAddress);

  const implementationV1Address = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("V1 实现合约地址:", implementationV1Address);

  const adminAddress = await upgrades.erc1967.getAdminAddress(proxyAddress);
  console.log("管理员合约地址:", adminAddress);

  // 验证 V1 部署
  const storedValue = await demo.retrieve();
  console.log("\n验证 V1 部署...");
  console.log("存储的值:", storedValue.toString());

  // 测试 store 功能
  console.log("\n测试 V1 store 功能...");
  const testValue = 100;
  await demo.store(testValue);
  const valueAfterStore = await demo.retrieve();
  console.log("store 后的值:", valueAfterStore.toString());

  if (valueAfterStore === BigInt(testValue)) {
    console.log("✅ V1 功能测试成功!\n");
  }

  // ==================== 第二步：升级到 DemoV2 ====================
  console.log("【第二步】升级到 DemoV2...\n");

  // 获取升级前的值
  const valueBefore = await demo.retrieve();
  console.log("升级前存储的值:", valueBefore.toString());

  // 检查升级兼容性
  console.log("\n检查升级兼容性...");
  const DemoV2 = await ethers.getContractFactory("DemoV2");

  try {
    await upgrades.validateUpgrade(proxyAddress, DemoV2);
    console.log("✅ 升级兼容性检查通过");
  } catch (error) {
    console.error("❌ 升级兼容性检查失败:", error);
    process.exit(1);
  }

  // 执行升级
  console.log("\n正在升级合约到 V2...");
  const demoV2 = await upgrades.upgradeProxy(proxyAddress, DemoV2);
  await demoV2.waitForDeployment();

  console.log("✅ 合约升级成功!");

  // 获取新的实现合约地址
  const implementationV2Address = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("V2 实现合约地址:", implementationV2Address);

  // 验证升级
  console.log("\n验证升级...");
  const valueAfter = await demoV2.retrieve();
  console.log("升级后存储的值:", valueAfter.toString());

  if (valueBefore === valueAfter) {
    console.log("✅ 状态保留验证成功!");
  } else {
    console.log("❌ 状态保留验证失败!");
  }

  // 测试新功能 increment
  console.log("\n测试 V2 新增的 increment 功能...");
  await demoV2.increment();
  const incrementedValue = await demoV2.retrieve();
  console.log("increment 后的值:", incrementedValue.toString());

  if (incrementedValue === valueAfter + 1n) {
    console.log("✅ increment 功能测试成功!");
  }

  // 测试多次 increment
  console.log("\n测试多次 increment...");
  await demoV2.increment();
  await demoV2.increment();
  const finalValue = await demoV2.retrieve();
  console.log("最终值:", finalValue.toString());

  // 输出完整信息汇总
  console.log("\n==================== 部署和升级信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", proxyAddress);
  console.log("V1 实现合约地址:", implementationV1Address);
  console.log("V2 实现合约地址:", implementationV2Address);
  console.log("管理员合约地址:", adminAddress);
  console.log("\n值的变化:");
  console.log("  初始值:", initialValue);
  console.log("  store 后:", testValue);
  console.log("  升级后:", valueAfter.toString());
  console.log("  最终值:", finalValue.toString());
  console.log("\nV2 新增功能: increment()");
  console.log("===========================================================\n");

  return {
    proxy: proxyAddress,
    implementationV1: implementationV1Address,
    implementationV2: implementationV2Address,
    admin: adminAddress,
  };
}

// 执行部署和升级
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
