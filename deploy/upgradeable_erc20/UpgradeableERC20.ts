import { ethers } from "hardhat";
import { upgrades } from "hardhat";

async function main() {
  console.log("开始部署 UpgradeableERC20 合约...\n");

  // 获取部署者账户
  const [deployer] = await ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // 设置代币参数
  const name = "Upgradeable Token";
  const symbol = "UPG";
  const initialSupply = 1000000; // 1,000,000 tokens (without decimals)
  const owner = deployer.address;

  console.log("代币参数:");
  console.log("  名称:", name);
  console.log("  符号:", symbol);
  console.log("  初始供应量:", initialSupply, "tokens");
  console.log("  拥有者:", owner);

  // 获取合约工厂
  const UpgradeableERC20 = await ethers.getContractFactory("UpgradeableERC20");
  console.log("\n正在部署 UpgradeableERC20 代理合约...");

  // 部署可升级合约（使用 UUPS 模式）
  const token = await upgrades.deployProxy(UpgradeableERC20, [name, symbol, initialSupply, owner], {
    initializer: "initialize",
    kind: "uups",
  });

  await token.waitForDeployment();

  const tokenAddress = await token.getAddress();
  console.log("\n✅ UpgradeableERC20 代理合约部署成功!");
  console.log("代理合约地址:", tokenAddress);

  // 获取实现合约地址
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(tokenAddress);
  console.log("实现合约地址:", implementationAddress);

  // 验证部署
  console.log("\n验证部署...");
  const tokenName = await token.name();
  const tokenSymbol = await token.symbol();
  const totalSupply = await token.totalSupply();
  const ownerBalance = await token.balanceOf(owner);

  console.log("代币名称:", tokenName);
  console.log("代币符号:", tokenSymbol);
  console.log("总供应量:", ethers.formatEther(totalSupply), "tokens");
  console.log("拥有者余额:", ethers.formatEther(ownerBalance), "tokens");

  if (tokenName === name && tokenSymbol === symbol) {
    console.log("✅ 部署验证成功!\n");
  } else {
    console.log("❌ 部署验证失败!\n");
  }

  // 验证角色
  console.log("验证角色分配...");
  const adminRole = await token.DEFAULT_ADMIN_ROLE();
  const minterRole = await token.MINTER_ROLE();
  const pauserRole = await token.PAUSER_ROLE();
  const upgraderRole = await token.UPGRADER_ROLE();

  const hasAdmin = await token.hasRole(adminRole, owner);
  const hasMinter = await token.hasRole(minterRole, owner);
  const hasPauser = await token.hasRole(pauserRole, owner);
  const hasUpgrader = await token.hasRole(upgraderRole, owner);

  console.log("DEFAULT_ADMIN_ROLE:", hasAdmin ? "✅" : "❌");
  console.log("MINTER_ROLE:", hasMinter ? "✅" : "❌");
  console.log("PAUSER_ROLE:", hasPauser ? "✅" : "❌");
  console.log("UPGRADER_ROLE:", hasUpgrader ? "✅" : "❌");

  // 测试基本功能
  console.log("\n测试基本功能...");

  // 测试铸造
  const mintAmount = ethers.parseEther("1000");
  await token.mint(deployer.address, mintAmount);
  const newBalance = await token.balanceOf(deployer.address);
  console.log("铸造后余额:", ethers.formatEther(newBalance), "tokens");

  // 输出部署信息汇总
  console.log("\n==================== 部署信息汇总 ====================");
  console.log("网络:", (await ethers.provider.getNetwork()).name);
  console.log("代理合约地址:", tokenAddress);
  console.log("实现合约地址:", implementationAddress);
  console.log("代币名称:", name);
  console.log("代币符号:", symbol);
  console.log("初始供应量:", initialSupply, "tokens");
  console.log("当前总供应量:", ethers.formatEther(await token.totalSupply()), "tokens");
  console.log("====================================================\n");

  console.log("⚠️  请保存代理合约地址用于升级:");
  console.log("export UPGRADEABLE_ERC20_PROXY=" + tokenAddress);
  console.log("或");
  console.log(
    "UPGRADEABLE_ERC20_PROXY=" +
      tokenAddress +
      " npx hardhat run deploy/upgradeable_erc20/UpgradeableERC20V2.ts --network <network>\n",
  );

  return {
    proxy: tokenAddress,
    implementation: implementationAddress,
  };
}

// 执行部署
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
