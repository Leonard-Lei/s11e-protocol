import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { deployUpgradeableERC20V2Fixture } from "./UpgradeableERC20.fixture";

describe("UpgradeableERC20V2", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("升级后的部署", function () {
    beforeEach(async function () {
      const { token, tokenAddress, name, symbol, initialSupply, maxSupply, owner, addr1, addr2, addr3 } =
        await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.tokenAddress = tokenAddress;
      this.name = name;
      this.symbol = symbol;
      this.initialSupply = initialSupply;
      this.maxSupply = maxSupply;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
      this.addr3 = addr3;
    });

    it("应该保留代币名称", async function () {
      expect(await this.token.name()).to.equal(this.name);
    });

    it("应该保留代币符号", async function () {
      expect(await this.token.symbol()).to.equal(this.symbol);
    });

    it("应该保留总供应量", async function () {
      const expectedSupply = ethers.parseEther(this.initialSupply.toString());
      expect(await this.token.totalSupply()).to.equal(expectedSupply);
    });

    it("应该保留拥有者余额", async function () {
      const expectedSupply = ethers.parseEther(this.initialSupply.toString());
      expect(await this.token.balanceOf(this.owner.address)).to.equal(expectedSupply);
    });

    it("代理地址应该保持不变", async function () {
      expect(this.tokenAddress).to.be.properAddress;
    });

    it("应该正确设置最大供应量", async function () {
      expect(await this.token.maxSupply()).to.equal(this.maxSupply);
    });
  });

  describe("继承的功能", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("应该能够转账", async function () {
      const amount = ethers.parseEther("100");
      await this.token.transfer(this.addr1.address, amount);
      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amount);
    });

    it("应该能够暂停", async function () {
      await this.token.pause();
      expect(await this.token.paused()).to.be.true;
    });

    it("应该能够销毁", async function () {
      const balanceBefore = await this.token.balanceOf(this.owner.address);
      const burnAmount = ethers.parseEther("100");
      await this.token.burn(burnAmount);
      expect(await this.token.balanceOf(this.owner.address)).to.equal(balanceBefore - burnAmount);
    });
  });

  describe("V2 新增：最大供应量限制", function () {
    beforeEach(async function () {
      const { token, maxSupply, owner, addr1 } = await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.maxSupply = maxSupply;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("应该能够查询最大供应量", async function () {
      expect(await this.token.maxSupply()).to.equal(this.maxSupply);
    });

    it("铸造不应该超过最大供应量", async function () {
      const currentSupply = await this.token.totalSupply();
      const excessAmount = this.maxSupply - currentSupply + ethers.parseEther("1");

      await expect(this.token.mint(this.addr1.address, excessAmount)).to.be.revertedWith(
        "UpgradeableERC20V2: Exceeds max supply",
      );
    });

    it("应该能够铸造到最大供应量", async function () {
      const currentSupply = await this.token.totalSupply();
      const remainingSupply = this.maxSupply - currentSupply;

      await this.token.mint(this.addr1.address, remainingSupply);
      expect(await this.token.totalSupply()).to.equal(this.maxSupply);
    });
  });

  describe("V2 新增：批量转账功能", function () {
    beforeEach(async function () {
      const { token, owner, addr1, addr2, addr3 } = await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
      this.addr3 = addr3;
    });

    it("管理员应该能够批量转账", async function () {
      const recipients = [this.addr1.address, this.addr2.address, this.addr3.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200"), ethers.parseEther("300")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.not.be.reverted;

      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amounts[0]);
      expect(await this.token.balanceOf(this.addr2.address)).to.equal(amounts[1]);
      expect(await this.token.balanceOf(this.addr3.address)).to.equal(amounts[2]);
    });

    it("批量转账应该减少发送者余额", async function () {
      const balanceBefore = await this.token.balanceOf(this.owner.address);
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200")];
      const totalTransferred = amounts[0] + amounts[1];

      await this.token.batchTransfer(recipients, amounts);
      expect(await this.token.balanceOf(this.owner.address)).to.equal(balanceBefore - totalTransferred);
    });

    it("非管理员不应该能够批量转账", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200")];

      await expect(this.token.connect(this.addr1).batchTransfer(recipients, amounts)).to.be.revertedWithCustomError(
        this.token,
        "AccessControlUnauthorizedAccount",
      );
    });

    it("数组长度不匹配应该失败", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.be.revertedWith(
        "UpgradeableERC20V2: Array length mismatch",
      );
    });

    it("余额不足时批量转账应该失败", async function () {
      const balance = await this.token.balanceOf(this.owner.address);
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [balance, ethers.parseEther("1")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.be.revertedWithCustomError(
        this.token,
        "ERC20InsufficientBalance",
      );
    });
  });

  describe("V2 新增：getTokenInfo 功能", function () {
    beforeEach(async function () {
      const { token, name, symbol, maxSupply } = await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.name = name;
      this.symbol = symbol;
      this.maxSupply = maxSupply;
    });

    it("应该返回正确的代币信息", async function () {
      const tokenInfo = await this.token.getTokenInfo();
      expect(tokenInfo[0]).to.equal(this.name); // name
      expect(tokenInfo[1]).to.equal(this.symbol); // symbol
      expect(tokenInfo[2]).to.equal(18); // decimals
      expect(tokenInfo[4]).to.equal(this.maxSupply); // maxSupply
    });
  });

  describe("状态保留测试", function () {
    beforeEach(async function () {
      const { token, initialSupply } = await this.loadFixture(deployUpgradeableERC20V2Fixture);
      this.token = token;
      this.initialSupply = initialSupply;
    });

    it("升级前的供应量应该在升级后保留", async function () {
      const expectedSupply = ethers.parseEther(this.initialSupply.toString());
      expect(await this.token.totalSupply()).to.equal(expectedSupply);
    });

    it("升级后的操作应该正常", async function () {
      const mintAmount = ethers.parseEther("1000");
      await this.token.mint(this.token.target, mintAmount);

      const totalSupply = await this.token.totalSupply();
      const expectedSupply = ethers.parseEther(this.initialSupply.toString()) + mintAmount;
      expect(totalSupply).to.equal(expectedSupply);
    });
  });
});
