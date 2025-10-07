import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("开始部署 Demo 合约...\n");

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // 设置初始值
  const initialValue = 42;
  console.log("初始值:", initialValue);

  // 获取合约工厂
  const Demo = await ethers.getContractFactory("Demo");
  console.log("正在部署 Demo 代理合约...");

  // 部署可升级合约
  const demo = await upgrades.deployProxy(Demo, [initialValue], {
    initializer: "initialize",
    kind: "transparent", // 使用透明代理模式
  });

  await demo.waitForDeployment();

  const demoAddress = await demo.getAddress();
  console.log("\n✅ Demo 代理合约部署成功!");
  console.log("代理合约地址:", demoAddress);

  // 获取实现合约地址
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(demoAddress);
  console.log("实现合约地址:", implementationAddress);

  // 获取管理员地址
  const adminAddress = await upgrades.erc1967.getAdminAddress(demoAddress);
  console.log("管理员合约地址:", adminAddress);

  // 验证部署
  console.log("\n验证部署...");
  const storedValue = await demo.retrieve();
  console.log("存储的值:", storedValue.toString());

  if (storedValue === BigInt(initialValue)) {
    console.log("✅ 部署验证成功!\n");
  } else {
    console.log("❌ 部署验证失败!\n");
  }

  // 测试 store 功能
  console.log("测试 store 功能...");
  const testValue = 100;
  const tx = await demo.store(testValue);
  await tx.wait();
  const newValue = await demo.retrieve();
  console.log("新存储的值:", newValue.toString());

  if (newValue === BigInt(testValue)) {
    console.log("✅ store 功能测试成功!\n");
  } else {
    console.log("❌ store 功能测试失败!\n");
  }

  // 输出部署信息汇总
  console.log("==================== 部署信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", demoAddress);
  console.log("实现合约地址:", implementationAddress);
  console.log("管理员合约地址:", adminAddress);
  console.log("初始值:", initialValue);
  console.log("当前值:", newValue.toString());
  console.log("====================================================\n");

  return {
    proxy: demoAddress,
    implementation: implementationAddress,
    admin: adminAddress,
  };
}

// 执行部署
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
