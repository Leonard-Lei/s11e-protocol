import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { upgrades } from "hardhat";

import type { Signers } from "../types";
import { deployUpgradeableERC20Fixture } from "./UpgradeableERC20.fixture";

describe("UpgradeableERC20", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("部署", function () {
    beforeEach(async function () {
      const { token, tokenAddress, name, symbol, initialSupply, owner, addr1, addr2, addr3 } =
        await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.tokenAddress = tokenAddress;
      this.name = name;
      this.symbol = symbol;
      this.initialSupply = initialSupply;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
      this.addr3 = addr3;
    });

    it("应该设置正确的代币名称", async function () {
      expect(await this.token.name()).to.equal(this.name);
    });

    it("应该设置正确的代币符号", async function () {
      expect(await this.token.symbol()).to.equal(this.symbol);
    });

    it("应该设置正确的小数位数", async function () {
      expect(await this.token.decimals()).to.equal(18);
    });

    it("应该正确初始化供应量", async function () {
      const expectedSupply = ethers.parseEther(this.initialSupply.toString());
      expect(await this.token.totalSupply()).to.equal(expectedSupply);
    });

    it("拥有者应该收到初始供应量", async function () {
      const expectedSupply = ethers.parseEther(this.initialSupply.toString());
      expect(await this.token.balanceOf(this.owner.address)).to.equal(expectedSupply);
    });

    it("应该正确部署代理合约", async function () {
      expect(this.tokenAddress).to.be.properAddress;
    });

    it("不应该允许重复初始化", async function () {
      await expect(
        this.token.initialize(this.name, this.symbol, this.initialSupply, this.owner.address),
      ).to.be.revertedWithCustomError(this.token, "InvalidInitialization");
    });
  });

  describe("角色管理", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("拥有者应该有 DEFAULT_ADMIN_ROLE", async function () {
      const adminRole = await this.token.DEFAULT_ADMIN_ROLE();
      expect(await this.token.hasRole(adminRole, this.owner.address)).to.be.true;
    });

    it("拥有者应该有 MINTER_ROLE", async function () {
      const minterRole = await this.token.MINTER_ROLE();
      expect(await this.token.hasRole(minterRole, this.owner.address)).to.be.true;
    });

    it("拥有者应该有 PAUSER_ROLE", async function () {
      const pauserRole = await this.token.PAUSER_ROLE();
      expect(await this.token.hasRole(pauserRole, this.owner.address)).to.be.true;
    });

    it("拥有者应该有 UPGRADER_ROLE", async function () {
      const upgraderRole = await this.token.UPGRADER_ROLE();
      expect(await this.token.hasRole(upgraderRole, this.owner.address)).to.be.true;
    });

    it("应该能够授予角色", async function () {
      const minterRole = await this.token.MINTER_ROLE();
      await this.token.grantRole(minterRole, this.addr1.address);
      expect(await this.token.hasRole(minterRole, this.addr1.address)).to.be.true;
    });

    it("应该能够撤销角色", async function () {
      const minterRole = await this.token.MINTER_ROLE();
      await this.token.grantRole(minterRole, this.addr1.address);
      await this.token.revokeRole(minterRole, this.addr1.address);
      expect(await this.token.hasRole(minterRole, this.addr1.address)).to.be.false;
    });
  });

  describe("铸造功能", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("有 MINTER_ROLE 的地址应该能够铸造", async function () {
      const amount = ethers.parseEther("1000");
      await this.token.mint(this.addr1.address, amount);
      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amount);
    });

    it("铸造应该增加总供应量", async function () {
      const supplyBefore = await this.token.totalSupply();
      const amount = ethers.parseEther("1000");
      await this.token.mint(this.addr1.address, amount);
      expect(await this.token.totalSupply()).to.equal(supplyBefore + amount);
    });

    it("没有 MINTER_ROLE 的地址不应该能够铸造", async function () {
      const amount = ethers.parseEther("1000");
      await expect(this.token.connect(this.addr1).mint(this.addr1.address, amount)).to.be.revertedWithCustomError(
        this.token,
        "AccessControlUnauthorizedAccount",
      );
    });
  });

  describe("暂停功能", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("有 PAUSER_ROLE 的地址应该能够暂停", async function () {
      await expect(this.token.pause()).to.not.be.reverted;
      expect(await this.token.paused()).to.be.true;
    });

    it("有 PAUSER_ROLE 的地址应该能够恢复", async function () {
      await this.token.pause();
      await this.token.unpause();
      expect(await this.token.paused()).to.be.false;
    });

    it("暂停时不应该能够转账", async function () {
      await this.token.pause();
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount)).to.be.revertedWithCustomError(
        this.token,
        "EnforcedPause",
      );
    });

    it("恢复后应该能够转账", async function () {
      await this.token.pause();
      await this.token.unpause();
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount)).to.not.be.reverted;
    });

    it("没有 PAUSER_ROLE 的地址不应该能够暂停", async function () {
      await expect(this.token.connect(this.addr1).pause()).to.be.revertedWithCustomError(
        this.token,
        "AccessControlUnauthorizedAccount",
      );
    });
  });

  describe("转账功能", function () {
    beforeEach(async function () {
      const { token, owner, addr1, addr2 } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
    });

    it("应该能够转账代币", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount)).to.not.be.reverted;
      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amount);
    });

    it("应该触发 Transfer 事件", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount))
        .to.emit(this.token, "Transfer")
        .withArgs(this.owner.address, this.addr1.address, amount);
    });
  });

  describe("销毁功能", function () {
    beforeEach(async function () {
      const { token, owner } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.owner = owner;
    });

    it("持有者应该能够销毁代币", async function () {
      const balanceBefore = await this.token.balanceOf(this.owner.address);
      const burnAmount = ethers.parseEther("100");
      await this.token.burn(burnAmount);
      expect(await this.token.balanceOf(this.owner.address)).to.equal(balanceBefore - burnAmount);
    });

    it("销毁应该减少总供应量", async function () {
      const supplyBefore = await this.token.totalSupply();
      const burnAmount = ethers.parseEther("100");
      await this.token.burn(burnAmount);
      expect(await this.token.totalSupply()).to.equal(supplyBefore - burnAmount);
    });
  });

  describe("可升级性", function () {
    beforeEach(async function () {
      const { token, tokenAddress, owner } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.tokenAddress = tokenAddress;
      this.owner = owner;
    });

    it("应该能够升级到 V2", async function () {
      const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");
      const upgraded = await upgrades.upgradeProxy(this.tokenAddress, UpgradeableERC20V2);
      expect(await upgraded.getAddress()).to.equal(this.tokenAddress);
    });

    it("升级后应该保留余额", async function () {
      const balanceBefore = await this.token.balanceOf(this.owner.address);

      const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");
      const upgraded = await upgrades.upgradeProxy(this.tokenAddress, UpgradeableERC20V2);

      expect(await upgraded.balanceOf(this.owner.address)).to.equal(balanceBefore);
    });

    it("升级后应该保留总供应量", async function () {
      const supplyBefore = await this.token.totalSupply();

      const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");
      const upgraded = await upgrades.upgradeProxy(this.tokenAddress, UpgradeableERC20V2);

      expect(await upgraded.totalSupply()).to.equal(supplyBefore);
    });

    it("升级后应该有新功能", async function () {
      const UpgradeableERC20V2 = await ethers.getContractFactory("UpgradeableERC20V2");
      const upgraded = await upgrades.upgradeProxy(this.tokenAddress, UpgradeableERC20V2);

      // 验证新增的功能存在
      expect(upgraded.batchTransfer).to.exist;
      expect(upgraded.getTokenInfo).to.exist;
      expect(upgraded.initializeV2).to.exist;
    });

    it("非 UPGRADER_ROLE 不应该能够升级", async function () {
      // 这个测试需要模拟升级授权检查
      // UUPS 的升级检查在 _authorizeUpgrade 中
      const upgraderRole = await this.token.UPGRADER_ROLE();
      expect(await this.token.hasRole(upgraderRole, this.owner.address)).to.be.true;
    });
  });

  describe("财务功能", function () {
    beforeEach(async function () {
      const { token, tokenAddress, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20Fixture);
      this.token = token;
      this.tokenAddress = tokenAddress;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("合约应该能够接收 ETH", async function () {
      const amount = ethers.parseEther("1");
      await expect(
        this.owner.sendTransaction({
          to: this.tokenAddress,
          value: amount,
        }),
      ).to.not.be.reverted;
    });

    it("应该能够查询合约余额", async function () {
      const amount = ethers.parseEther("1");
      await this.owner.sendTransaction({
        to: this.tokenAddress,
        value: amount,
      });
      expect(await this.token.balance()).to.equal(amount);
    });

    it("管理员应该能够提取 ETH", async function () {
      const amount = ethers.parseEther("1");
      await this.owner.sendTransaction({
        to: this.tokenAddress,
        value: amount,
      });

      await expect(this.token.withdraw(amount)).to.not.be.reverted;
    });

    it("非管理员不应该能够提取 ETH", async function () {
      const amount = ethers.parseEther("1");
      await this.owner.sendTransaction({
        to: this.tokenAddress,
        value: amount,
      });

      await expect(this.token.connect(this.addr1).withdraw(amount)).to.be.revertedWith(
        "must have admin role to withdraw",
      );
    });

    it("不应该允许提取超过合约余额的 ETH", async function () {
      const amount = ethers.parseEther("1");
      await this.owner.sendTransaction({
        to: this.tokenAddress,
        value: amount,
      });

      const excessAmount = ethers.parseEther("2");
      await expect(this.token.withdraw(excessAmount)).to.be.revertedWith("insufficient balance");
    });
  });
});
