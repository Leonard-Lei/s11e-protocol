import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const tokenName = "Standard Token";
  const tokenSymbol = "STD";
  const initialSupply = hre.ethers.parseEther("1000000000");
  const owner = deployer;

  const standardERC20 = await deploy("StandardERC20", {
    from: deployer,
    args: [tokenName, tokenSymbol, initialSupply, owner],
    log: true,
  });

  console.log(`StandardERC20 deployed at: ${standardERC20.address}`);
  console.log(`  Name: ${tokenName}`);
  console.log(`  Symbol: ${tokenSymbol}`);
  console.log(`  Initial Supply: ${hre.ethers.formatEther(initialSupply)}`);
  console.log(`  Owner: ${owner}`);
};

export default func;
func.id = "deploy_standard_erc20";
func.tags = ["StandardERC20"];
