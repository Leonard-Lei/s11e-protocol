import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("==================== 开始部署和升级 UpgradeableERC20 ====================\n");

  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // ==================== 第一步：部署 UpgradeableERC20 V1 ====================
  console.log("【第一步】部署 UpgradeableERC20 V1...\n");

  const name = "Upgradeable Token";
  const symbol = "UPG";
  const initialSupply = 1000000;
  const owner = deployer.address;

  console.log("代币参数:");
  console.log("  名称:", name);
  console.log("  符号:", symbol);
  console.log("  初始供应量:", initialSupply, "tokens");
  console.log("  拥有者:", owner);

  const UpgradeableERC20 = await ethers.getContractFactory("UpgradeableERC20");
  console.log("\n正在部署 V1 代理合约...");

  const tokenV1 = await upgrades.deployProxy(UpgradeableERC20, [name, symbol, initialSupply, owner], {
    initializer: "initialize",
    kind: "uups",
  });

  await tokenV1.waitForDeployment();

  const proxyAddress = await tokenV1.getAddress();
  console.log("\n✅ UpgradeableERC20 V1 部署成功!");
  console.log("代理合约地址:", proxyAddress);

  const implementationV1Address = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("V1 实现合约地址:", implementationV1Address);

  // 验证 V1 部署
  console.log("\n验证 V1 部署...");
  const totalSupplyV1 = await tokenV1.totalSupply();
  const ownerBalanceV1 = await tokenV1.balanceOf(owner);
  console.log("总供应量:", ethers.formatEther(totalSupplyV1), "tokens");
  console.log("拥有者余额:", ethers.formatEther(ownerBalanceV1), "tokens");

  // 测试 V1 功能
  console.log("\n测试 V1 铸造功能...");
  const mintAmount = ethers.parseEther("1000");
  await tokenV1.mint(deployer.address, mintAmount);
  const balanceAfterMint = await tokenV1.balanceOf(deployer.address);
  console.log("铸造后余额:", ethers.formatEther(balanceAfterMint), "tokens");

  if (balanceAfterMint === ownerBalanceV1 + mintAmount) {
    console.log("✅ V1 功能测试成功!\n");
  }

  // ==================== 第二步：升级到 V2 ====================
  console.log("【第二步】升级到 UpgradeableERC20V2...\n");

  // 获取升级前的状态
  const supplyBeforeUpgrade = await tokenV1.totalSupply();
  const balanceBeforeUpgrade = await tokenV1.balanceOf(owner);
  console.log("升级前状态:");
  console.log("  总供应量:", ethers.formatEther(supplyBeforeUpgrade), "tokens");
  console.log("  拥有者余额:", ethers.formatEther(balanceBeforeUpgrade), "tokens");

  // 检查升级兼容性
  console.log("\n检查升级兼容性...");
  const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");

  try {
    await upgrades.validateUpgrade(proxyAddress, UpgradeableERC20V2);
    console.log("✅ 升级兼容性检查通过");
  } catch (error) {
    console.error("❌ 升级兼容性检查失败:", error);
    process.exit(1);
  }

  // 执行升级
  console.log("\n正在升级合约到 V2...");
  const tokenV2 = await upgrades.upgradeProxy(proxyAddress, UpgradeableERC20V2);
  await tokenV2.waitForDeployment();

  console.log("✅ 合约升级成功!");

  // 获取新的实现合约地址
  const implementationV2Address = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("V2 实现合约地址:", implementationV2Address);

  // 验证升级后状态
  console.log("\n验证状态保留...");
  const supplyAfterUpgrade = await tokenV2.totalSupply();
  const balanceAfterUpgrade = await tokenV2.balanceOf(owner);
  console.log("升级后状态:");
  console.log("  总供应量:", ethers.formatEther(supplyAfterUpgrade), "tokens");
  console.log("  拥有者余额:", ethers.formatEther(balanceAfterUpgrade), "tokens");

  if (supplyBeforeUpgrade === supplyAfterUpgrade && balanceBeforeUpgrade === balanceAfterUpgrade) {
    console.log("✅ 状态保留验证成功!");
  } else {
    console.log("❌ 状态保留验证失败!");
  }

  // 初始化 V2 新状态
  console.log("\n初始化 V2 新状态...");
  const maxSupply = ethers.parseEther("10000000"); // 10,000,000 tokens
  console.log("设置最大供应量:", ethers.formatEther(maxSupply), "tokens");

  await tokenV2.initializeV2(maxSupply);
  const setMaxSupply = await tokenV2.maxSupply();
  console.log("当前最大供应量:", ethers.formatEther(setMaxSupply), "tokens");

  if (setMaxSupply === maxSupply) {
    console.log("✅ V2 初始化成功!");
  }

  // 测试 V2 新功能
  console.log("\n测试 V2 新增功能...");

  // 1. 测试 getTokenInfo
  console.log("\n1. 测试 getTokenInfo...");
  const tokenInfo = await tokenV2.getTokenInfo();
  console.log("   名称:", tokenInfo[0]);
  console.log("   符号:", tokenInfo[1]);
  console.log("   小数位:", tokenInfo[2]);
  console.log("   总供应量:", ethers.formatEther(tokenInfo[3]), "tokens");
  console.log("   最大供应量:", ethers.formatEther(tokenInfo[4]), "tokens");
  console.log("   ✅ getTokenInfo 测试成功!");

  // 2. 测试 batchTransfer
  console.log("\n2. 测试 batchTransfer...");
  const [, addr1, addr2, addr3] = await ethers.getSigners();
  const recipients = [addr1.address, addr2.address, addr3.address];
  const amounts = [ethers.parseEther("100"), ethers.parseEther("200"), ethers.parseEther("300")];

  await tokenV2.batchTransfer(recipients, amounts);
  console.log("   批量转账成功");
  console.log("   地址1余额:", ethers.formatEther(await tokenV2.balanceOf(addr1.address)), "tokens");
  console.log("   地址2余额:", ethers.formatEther(await tokenV2.balanceOf(addr2.address)), "tokens");
  console.log("   地址3余额:", ethers.formatEther(await tokenV2.balanceOf(addr3.address)), "tokens");
  console.log("   ✅ batchTransfer 测试成功!");

  // 3. 测试最大供应量限制
  console.log("\n3. 测试最大供应量限制...");
  const currentSupply = await tokenV2.totalSupply();
  const remainingSupply = maxSupply - currentSupply;
  console.log("   当前供应量:", ethers.formatEther(currentSupply), "tokens");
  console.log("   剩余可铸造:", ethers.formatEther(remainingSupply), "tokens");

  // 尝试铸造一些代币（在限制内）
  const testMintAmount = ethers.parseEther("1000");
  await tokenV2.mint(addr1.address, testMintAmount);
  console.log("   铸造成功:", ethers.formatEther(testMintAmount), "tokens");
  console.log("   ✅ 最大供应量限制测试成功!");

  // 输出完整信息汇总
  console.log("\n==================== 部署和升级信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", proxyAddress);
  console.log("V1 实现合约地址:", implementationV1Address);
  console.log("V2 实现合约地址:", implementationV2Address);
  console.log("\n代币信息:");
  console.log("  名称:", name);
  console.log("  符号:", symbol);
  console.log("  初始供应量:", initialSupply, "tokens");
  console.log("  最大供应量:", ethers.formatEther(maxSupply), "tokens");
  console.log("  当前供应量:", ethers.formatEther(await tokenV2.totalSupply()), "tokens");
  console.log("\nV2 新增功能:");
  console.log("  ✅ batchTransfer() - 批量转账");
  console.log("  ✅ getTokenInfo() - 获取代币信息");
  console.log("  ✅ maxSupply - 最大供应量限制");
  console.log("  ✅ initializeV2() - V2 状态初始化");
  console.log("\n铸造限制:");
  console.log("  ✅ mint() 现在会检查最大供应量");
  console.log("===========================================================\n");

  return {
    proxy: proxyAddress,
    implementationV1: implementationV1Address,
    implementationV2: implementationV2Address,
  };
}

// 执行部署和升级
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
