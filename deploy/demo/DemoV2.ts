import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("开始升级 Demo 合约到 DemoV2...\n");

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // 代理合约地址（需要替换为实际部署的地址）
  const PROXY_ADDRESS = process.env.DEMO_PROXY_ADDRESS || "0x694e79297d3642eb5e156ddca7ffc5ee927e0d85";

  if (!PROXY_ADDRESS) {
    console.error("❌ 错误: 请设置环境变量 DEMO_PROXY_ADDRESS");
    console.log("使用方法: DEMO_PROXY_ADDRESS=0x... npx hardhat run deploy/demo/DemoV2.ts --network <network>");
    process.exit(1);
  }

  console.log("代理合约地址:", PROXY_ADDRESS);

  // 获取升级前的值
  console.log("\n获取升级前的状态...");
  const Demo = await ethers.getContractFactory("Demo");
  const demoV1 = Demo.attach(PROXY_ADDRESS);
  const valueBefore = await demoV1.retrieve();
  console.log("升级前存储的值:", valueBefore.toString());

  // 检查升级兼容性
  console.log("\n检查升级兼容性...");
  const DemoV2 = await ethers.getContractFactory("DemoV2");

  try {
    await upgrades.validateUpgrade(PROXY_ADDRESS, DemoV2);
    console.log("✅ 升级兼容性检查通过");
  } catch (error) {
    console.error("❌ 升级兼容性检查失败:", error);
    process.exit(1);
  }

  // 执行升级
  console.log("\n正在升级合约...");
  const demoV2 = await upgrades.upgradeProxy(PROXY_ADDRESS, DemoV2);
  await demoV2.waitForDeployment();

  console.log("✅ 合约升级成功!");

  // 获取新的实现合约地址
  const newImplementationAddress = await upgrades.erc1967.getImplementationAddress(PROXY_ADDRESS);
  console.log("新实现合约地址:", newImplementationAddress);

  // 验证升级
  console.log("\n验证升级...");
  const valueAfter = await demoV2.retrieve();
  console.log("升级后存储的值:", valueAfter.toString());

  if (valueBefore === valueAfter) {
    console.log("✅ 状态保留验证成功!");
  } else {
    console.log("❌ 状态保留验证失败!");
    console.log("预期值:", valueBefore.toString());
    console.log("实际值:", valueAfter.toString());
  }

  // 测试新功能
  console.log("\n测试新增的 increment 功能...");
  const tx = await demoV2.increment();
  await tx.wait();
  const incrementedValue = await demoV2.retrieve();
  console.log("increment 后的值:", incrementedValue.toString());

  if (incrementedValue === valueAfter + 1n) {
    console.log("✅ increment 功能测试成功!\n");
  } else {
    console.log("❌ increment 功能测试失败!\n");
  }

  // 测试 increment 多次
  console.log("测试多次 increment...");
  await demoV2.increment();
  await demoV2.increment();
  const finalValue = await demoV2.retrieve();
  console.log("最终值:", finalValue.toString());

  // 输出升级信息汇总
  console.log("\n==================== 升级信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", PROXY_ADDRESS);
  console.log("新实现合约地址:", newImplementationAddress);
  console.log("升级前的值:", valueBefore.toString());
  console.log("升级后的值:", valueAfter.toString());
  console.log("最终值:", finalValue.toString());
  console.log("新增功能: increment()");
  console.log("====================================================\n");

  return {
    proxy: PROXY_ADDRESS,
    implementation: newImplementationAddress,
  };
}

// 执行升级
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
