import { ethers } from "hardhat";
import { upgrades } from "hardhat";

export async function deployUpgradeableERC20Fixture() {
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();

  const name = "Upgradeable Token";
  const symbol = "UPG";
  const initialSupply = 1000000; // 1,000,000 tokens (without decimals)

  // 部署可升级的 UpgradeableERC20
  const UpgradeableERC20 = await ethers.getContractFactory("UpgradeableERC20");
  const token = await upgrades.deployProxy(UpgradeableERC20, [name, symbol, initialSupply, owner.address], {
    initializer: "initialize",
    kind: "uups", // 使用 UUPS 模式
  });
  await token.waitForDeployment();

  const tokenAddress = await token.getAddress();

  return { token, tokenAddress, name, symbol, initialSupply, owner, addr1, addr2, addr3 };
}

export async function deployUpgradeableERC20V2Fixture() {
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();

  const name = "Upgradeable Token";
  const symbol = "UPG";
  const initialSupply = 1000000;

  // 先部署 V1
  const UpgradeableERC20 = await ethers.getContractFactory("UpgradeableERC20");
  const tokenV1 = await upgrades.deployProxy(UpgradeableERC20, [name, symbol, initialSupply, owner.address], {
    initializer: "initialize",
    kind: "uups",
  });
  await tokenV1.waitForDeployment();

  const tokenAddress = await tokenV1.getAddress();

  // 升级到 V2
  const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");
  const token = await upgrades.upgradeProxy(tokenAddress, UpgradeableERC20V2);
  await token.waitForDeployment();

  // 初始化 V2 的新状态（设置最大供应量）
  const maxSupply = ethers.parseEther("10000000"); // 10,000,000 tokens
  await token.initializeV2(maxSupply);

  return { token, tokenAddress, name, symbol, initialSupply, maxSupply, owner, addr1, addr2, addr3 };
}
