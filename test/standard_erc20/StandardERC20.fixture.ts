import { ethers } from "hardhat";

export async function deployStandardERC20Fixture() {
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();

  const name = "Standard Token";
  const symbol = "STD";
  const initialSupply = ethers.parseEther("1000000"); // 1,000,000 tokens

  const StandardERC20 = await ethers.getContractFactory("StandardERC20");
  const token = await StandardERC20.deploy(name, symbol, initialSupply, owner.address);
  const tokenAddress = await token.getAddress();

  return { token, tokenAddress, name, symbol, initialSupply, owner, addr1, addr2, addr3 };
}
