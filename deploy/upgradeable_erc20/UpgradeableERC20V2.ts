import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("开始升级 UpgradeableERC20 到 V2...\n");

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // 代理合约地址（需要替换为实际部署的地址）
  const PROXY_ADDRESS = process.env.UPGRADEABLE_ERC20_PROXY || "0xEC0086a5d191BB54e34B972E74504F7E3c338425";

  if (!PROXY_ADDRESS) {
    console.error("❌ 错误: 请设置环境变量 UPGRADEABLE_ERC20_PROXY");
    console.log(
      "使用方法: UPGRADEABLE_ERC20_PROXY=0x... npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network <network>",
    );
    process.exit(1);
  }

  console.log("代理合约地址:", PROXY_ADDRESS);

  // 获取升级前的状态
  console.log("\n获取升级前的状态...");
  const UpgradeableERC20 = await ethers.getContractFactory("UpgradeableERC20");
  const tokenV1 = UpgradeableERC20.attach(PROXY_ADDRESS);

  const nameBefore = await tokenV1.name();
  const symbolBefore = await tokenV1.symbol();
  const totalSupplyBefore = await tokenV1.totalSupply();
  const ownerBalanceBefore = await tokenV1.balanceOf(deployer.address);

  console.log("升级前状态:");
  console.log("  名称:", nameBefore);
  console.log("  符号:", symbolBefore);
  console.log("  总供应量:", ethers.formatEther(totalSupplyBefore), "tokens");
  console.log("  拥有者余额:", ethers.formatEther(ownerBalanceBefore), "tokens");

  // 检查升级兼容性
  console.log("\n检查升级兼容性...");
  const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");

  try {
    await upgrades.validateUpgrade(PROXY_ADDRESS, UpgradeableERC20V2);
    console.log("✅ 升级兼容性检查通过");
  } catch (error) {
    console.error("❌ 升级兼容性检查失败:", error);
    process.exit(1);
  }

  // 执行升级
  console.log("\n正在升级合约到 V2...");
  const tokenV2 = await upgrades.upgradeProxy(PROXY_ADDRESS, UpgradeableERC20V2);
  await tokenV2.waitForDeployment();

  console.log("✅ 合约升级成功!");

  // 获取新的实现合约地址
  const newImplementationAddress = await upgrades.erc1967.getImplementationAddress(PROXY_ADDRESS);
  console.log("V2 实现合约地址:", newImplementationAddress);

  // 验证升级后状态
  console.log("\n验证升级后状态...");
  const nameAfter = await tokenV2.name();
  const symbolAfter = await tokenV2.symbol();
  const totalSupplyAfter = await tokenV2.totalSupply();
  const ownerBalanceAfter = await tokenV2.balanceOf(deployer.address);

  console.log("升级后状态:");
  console.log("  名称:", nameAfter);
  console.log("  符号:", symbolAfter);
  console.log("  总供应量:", ethers.formatEther(totalSupplyAfter), "tokens");
  console.log("  拥有者余额:", ethers.formatEther(ownerBalanceAfter), "tokens");

  // 验证状态保留
  if (
    nameBefore === nameAfter &&
    symbolBefore === symbolAfter &&
    totalSupplyBefore === totalSupplyAfter &&
    ownerBalanceBefore === ownerBalanceAfter
  ) {
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

  // 测试新功能
  console.log("\n测试 V2 新增功能...");

  // 测试 getTokenInfo
  console.log("\n1. 测试 getTokenInfo...");
  const tokenInfo = await tokenV2.getTokenInfo();
  console.log("   代币信息:", {
    name: tokenInfo[0],
    symbol: tokenInfo[1],
    decimals: tokenInfo[2],
    totalSupply: ethers.formatEther(tokenInfo[3]),
    maxSupply: ethers.formatEther(tokenInfo[4]),
  });

  // 测试 batchTransfer
  console.log("\n2. 测试 batchTransfer...");
  const [, addr1, addr2] = await ethers.getSigners();
  const recipients = [addr1.address, addr2.address];
  const amounts = [ethers.parseEther("100"), ethers.parseEther("200")];

  await tokenV2.batchTransfer(recipients, amounts);
  console.log("   批量转账成功");
  console.log("   地址1余额:", ethers.formatEther(await tokenV2.balanceOf(addr1.address)), "tokens");
  console.log("   地址2余额:", ethers.formatEther(await tokenV2.balanceOf(addr2.address)), "tokens");

  // 测试最大供应量限制
  console.log("\n3. 测试最大供应量限制...");
  const currentSupply = await tokenV2.totalSupply();
  const remainingSupply = maxSupply - currentSupply;
  console.log("   当前供应量:", ethers.formatEther(currentSupply), "tokens");
  console.log("   剩余可铸造:", ethers.formatEther(remainingSupply), "tokens");

  // 输出升级信息汇总
  console.log("\n==================== 升级信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", PROXY_ADDRESS);
  console.log("V2 实现合约地址:", newImplementationAddress);
  console.log("\n升级前状态:");
  console.log("  总供应量:", ethers.formatEther(totalSupplyBefore), "tokens");
  console.log("\n升级后状态:");
  console.log("  总供应量:", ethers.formatEther(totalSupplyAfter), "tokens");
  console.log("  最大供应量:", ethers.formatEther(maxSupply), "tokens");
  console.log("\nV2 新增功能:");
  console.log("  ✅ batchTransfer() - 批量转账");
  console.log("  ✅ getTokenInfo() - 获取代币信息");
  console.log("  ✅ maxSupply - 最大供应量限制");
  console.log("  ✅ initializeV2() - V2 初始化");
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
