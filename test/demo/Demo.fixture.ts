import { ethers } from "hardhat";
import { upgrades } from "hardhat";

export async function deployDemoFixture() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const initialValue = 42;
  console.log("---------------start deployDemoFixture-----------------");
  console.log("initialValue", initialValue);
  console.log("owner", owner.address);
  console.log("addr1", addr1.address);
  console.log("addr2", addr2.address);
  console.log("---------------end deployDemoFixture-----------------");
  // 部署可升级的 Demo 合约
  const Demo = await ethers.getContractFactory("Demo");
  console.log("---------------start deployDemo-----------------");
  const demo = await upgrades.deployProxy(Demo, [initialValue], {
    initializer: "initialize",
  });
  await demo.waitForDeployment();

  const demoAddress = await demo.getAddress();

  return { demo, demoAddress, initialValue, owner, addr1, addr2 };
}

export async function deployDemoV2Fixture() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const initialValue = 42;

  // 先部署 Demo V1
  const Demo = await ethers.getContractFactory("Demo");
  const demo = await upgrades.deployProxy(Demo, [initialValue], {
    initializer: "initialize",
  });
  await demo.waitForDeployment();

  const demoAddress = await demo.getAddress();

  // 升级到 DemoV2
  const DemoV2 = await ethers.getContractFactory("DemoV2");
  const demoV2 = await upgrades.upgradeProxy(demoAddress, DemoV2);
  await demoV2.waitForDeployment();

  return { demo: demoV2, demoAddress, initialValue, owner, addr1, addr2 };
}
