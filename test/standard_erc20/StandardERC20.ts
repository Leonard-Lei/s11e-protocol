import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { deployStandardERC20Fixture } from "./StandardERC20.fixture";

describe("StandardERC20", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("部署", function () {
    beforeEach(async function () {
      const { token, tokenAddress, name, symbol, initialSupply, owner, addr1, addr2, addr3 } =
        await this.loadFixture(deployStandardERC20Fixture);
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

    it("应该设置正确的拥有者", async function () {
      expect(await this.token.owner()).to.equal(this.owner.address);
    });

    it("应该正确设置最大供应量", async function () {
      const maxSupply = ethers.parseEther("10000000"); // 10,000,000 tokens
      expect(await this.token.MAX_SUPPLY()).to.equal(maxSupply);
    });

    it("初始总供应量应该为0", async function () {
      expect(await this.token.totalSupply()).to.equal(0);
    });
  });

  describe("getTokenInfo", function () {
    beforeEach(async function () {
      const { token, name, symbol } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.name = name;
      this.symbol = symbol;
    });

    it("应该返回正确的代币信息", async function () {
      const tokenInfo = await this.token.getTokenInfo();
      expect(tokenInfo[0]).to.equal(this.name); // name
      expect(tokenInfo[1]).to.equal(this.symbol); // symbol
      expect(tokenInfo[2]).to.equal(18); // decimals
      expect(tokenInfo[3]).to.equal(0); // totalSupply
      expect(tokenInfo[4]).to.equal(ethers.parseEther("10000000")); // maxSupply
    });
  });

  describe("铸造 (Mint)", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("拥有者应该能够铸造代币", async function () {
      const amount = ethers.parseEther("1000");
      await expect(this.token.mint(this.addr1.address, amount)).to.not.be.reverted;
      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amount);
    });

    it("铸造应该增加总供应量", async function () {
      const amount = ethers.parseEther("1000");
      await this.token.mint(this.addr1.address, amount);
      expect(await this.token.totalSupply()).to.equal(amount);
    });

    it("非拥有者不应该能够铸造代币", async function () {
      const amount = ethers.parseEther("1000");
      await expect(this.token.connect(this.addr1).mint(this.addr1.address, amount))
        .to.be.revertedWithCustomError(this.token, "OwnableUnauthorizedAccount")
        .withArgs(this.addr1.address);
    });

    it("不应该允许铸造超过最大供应量", async function () {
      const maxSupply = await this.token.MAX_SUPPLY();
      const excessAmount = maxSupply + ethers.parseEther("1");
      await expect(this.token.mint(this.addr1.address, excessAmount)).to.be.revertedWith("MyToken: Exceeds max supply");
    });

    it("应该能够铸造到最大供应量", async function () {
      const maxSupply = await this.token.MAX_SUPPLY();
      await this.token.mint(this.addr1.address, maxSupply);
      expect(await this.token.totalSupply()).to.equal(maxSupply);
    });

    it("铸造到最大供应量后不能再铸造", async function () {
      const maxSupply = await this.token.MAX_SUPPLY();
      await this.token.mint(this.addr1.address, maxSupply);

      const additionalAmount = ethers.parseEther("1");
      await expect(this.token.mint(this.addr1.address, additionalAmount)).to.be.revertedWith(
        "MyToken: Exceeds max supply",
      );
    });
  });

  describe("转账 (Transfer)", function () {
    beforeEach(async function () {
      const { token, owner, addr1, addr2 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;

      // 铸造一些代币
      this.mintAmount = ethers.parseEther("10000");
      await this.token.mint(this.owner.address, this.mintAmount);
    });

    it("应该能够转账代币", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount)).to.not.be.reverted;
      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amount);
    });

    it("转账应该减少发送者余额", async function () {
      const amount = ethers.parseEther("100");
      await this.token.transfer(this.addr1.address, amount);
      expect(await this.token.balanceOf(this.owner.address)).to.equal(this.mintAmount - amount);
    });

    it("不应该允许转账超过余额的代币", async function () {
      const excessAmount = this.mintAmount + ethers.parseEther("1");
      await expect(this.token.transfer(this.addr1.address, excessAmount)).to.be.revertedWithCustomError(
        this.token,
        "ERC20InsufficientBalance",
      );
    });

    it("应该触发 Transfer 事件", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.transfer(this.addr1.address, amount))
        .to.emit(this.token, "Transfer")
        .withArgs(this.owner.address, this.addr1.address, amount);
    });
  });

  describe("批量转账 (BatchTransfer)", function () {
    beforeEach(async function () {
      const { token, owner, addr1, addr2, addr3 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
      this.addr3 = addr3;

      // 铸造一些代币给拥有者
      this.mintAmount = ethers.parseEther("10000");
      await this.token.mint(this.owner.address, this.mintAmount);
    });

    it("拥有者应该能够批量转账", async function () {
      const recipients = [this.addr1.address, this.addr2.address, this.addr3.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200"), ethers.parseEther("300")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.not.be.reverted;

      expect(await this.token.balanceOf(this.addr1.address)).to.equal(amounts[0]);
      expect(await this.token.balanceOf(this.addr2.address)).to.equal(amounts[1]);
      expect(await this.token.balanceOf(this.addr3.address)).to.equal(amounts[2]);
    });

    it("批量转账应该减少拥有者余额", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200")];
      const totalTransferred = amounts[0] + amounts[1];

      await this.token.batchTransfer(recipients, amounts);
      expect(await this.token.balanceOf(this.owner.address)).to.equal(this.mintAmount - totalTransferred);
    });

    it("非拥有者不应该能够批量转账", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100"), ethers.parseEther("200")];

      await expect(this.token.connect(this.addr1).batchTransfer(recipients, amounts))
        .to.be.revertedWithCustomError(this.token, "OwnableUnauthorizedAccount")
        .withArgs(this.addr1.address);
    });

    it("数组长度不匹配应该失败", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [ethers.parseEther("100")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.be.revertedWith("MyToken: Array length mismatch");
    });

    it("余额不足时批量转账应该失败", async function () {
      const recipients = [this.addr1.address, this.addr2.address];
      const amounts = [this.mintAmount, ethers.parseEther("1")];

      await expect(this.token.batchTransfer(recipients, amounts)).to.be.revertedWithCustomError(
        this.token,
        "ERC20InsufficientBalance",
      );
    });
  });

  describe("授权 (Allowance)", function () {
    beforeEach(async function () {
      const { token, owner, addr1, addr2 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;

      this.mintAmount = ethers.parseEther("10000");
      await this.token.mint(this.owner.address, this.mintAmount);
    });

    it("应该能够授权代币", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.approve(this.addr1.address, amount)).to.not.be.reverted;
      expect(await this.token.allowance(this.owner.address, this.addr1.address)).to.equal(amount);
    });

    it("应该触发 Approval 事件", async function () {
      const amount = ethers.parseEther("100");
      await expect(this.token.approve(this.addr1.address, amount))
        .to.emit(this.token, "Approval")
        .withArgs(this.owner.address, this.addr1.address, amount);
    });

    it("被授权者应该能够使用 transferFrom", async function () {
      const amount = ethers.parseEther("100");
      await this.token.approve(this.addr1.address, amount);

      await expect(this.token.connect(this.addr1).transferFrom(this.owner.address, this.addr2.address, amount)).to.not
        .be.reverted;
      expect(await this.token.balanceOf(this.addr2.address)).to.equal(amount);
    });

    it("transferFrom 应该减少授权额度", async function () {
      const amount = ethers.parseEther("100");
      await this.token.approve(this.addr1.address, amount);

      const transferAmount = ethers.parseEther("60");
      await this.token.connect(this.addr1).transferFrom(this.owner.address, this.addr2.address, transferAmount);

      expect(await this.token.allowance(this.owner.address, this.addr1.address)).to.equal(amount - transferAmount);
    });

    it("不应该允许超过授权额度的 transferFrom", async function () {
      const amount = ethers.parseEther("100");
      await this.token.approve(this.addr1.address, amount);

      const excessAmount = ethers.parseEther("101");
      await expect(
        this.token.connect(this.addr1).transferFrom(this.owner.address, this.addr2.address, excessAmount),
      ).to.be.revertedWithCustomError(this.token, "ERC20InsufficientAllowance");
    });
  });

  describe("销毁 (Burn)", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;

      this.mintAmount = ethers.parseEther("10000");
      await this.token.mint(this.owner.address, this.mintAmount);
    });

    it("持有者应该能够销毁自己的代币", async function () {
      const burnAmount = ethers.parseEther("100");
      await expect(this.token.burn(burnAmount)).to.not.be.reverted;
      expect(await this.token.balanceOf(this.owner.address)).to.equal(this.mintAmount - burnAmount);
    });

    it("销毁应该减少总供应量", async function () {
      const burnAmount = ethers.parseEther("100");
      await this.token.burn(burnAmount);
      expect(await this.token.totalSupply()).to.equal(this.mintAmount - burnAmount);
    });

    it("不应该允许销毁超过余额的代币", async function () {
      const excessAmount = this.mintAmount + ethers.parseEther("1");
      await expect(this.token.burn(excessAmount)).to.be.revertedWithCustomError(this.token, "ERC20InsufficientBalance");
    });

    it("应该能够使用 burnFrom 销毁授权的代币", async function () {
      const amount = ethers.parseEther("100");
      await this.token.approve(this.addr1.address, amount);

      await expect(this.token.connect(this.addr1).burnFrom(this.owner.address, amount)).to.not.be.reverted;
      expect(await this.token.balanceOf(this.owner.address)).to.equal(this.mintAmount - amount);
    });

    it("burnFrom 应该减少授权额度", async function () {
      const amount = ethers.parseEther("100");
      await this.token.approve(this.addr1.address, amount);

      const burnAmount = ethers.parseEther("60");
      await this.token.connect(this.addr1).burnFrom(this.owner.address, burnAmount);

      expect(await this.token.allowance(this.owner.address, this.addr1.address)).to.equal(amount - burnAmount);
    });
  });

  describe("Permit (EIP-2612)", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;

      this.mintAmount = ethers.parseEther("10000");
      await this.token.mint(this.owner.address, this.mintAmount);
    });

    it("应该有正确的 domain separator", async function () {
      const domainSeparator = await this.token.DOMAIN_SEPARATOR();
      expect(domainSeparator).to.be.properHex(64);
    });

    it("应该有正确的 nonces", async function () {
      const nonce = await this.token.nonces(this.owner.address);
      expect(nonce).to.equal(0);
    });
  });

  describe("所有权 (Ownable)", function () {
    beforeEach(async function () {
      const { token, owner, addr1 } = await this.loadFixture(deployStandardERC20Fixture);
      this.token = token;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("应该能够转移所有权", async function () {
      await expect(this.token.transferOwnership(this.addr1.address)).to.not.be.reverted;
      expect(await this.token.owner()).to.equal(this.addr1.address);
    });

    it("转移所有权后原拥有者不应该能够铸造", async function () {
      await this.token.transferOwnership(this.addr1.address);

      const amount = ethers.parseEther("100");
      await expect(this.token.mint(this.addr1.address, amount))
        .to.be.revertedWithCustomError(this.token, "OwnableUnauthorizedAccount")
        .withArgs(this.owner.address);
    });

    it("新拥有者应该能够铸造", async function () {
      await this.token.transferOwnership(this.addr1.address);

      const amount = ethers.parseEther("100");
      await expect(this.token.connect(this.addr1).mint(this.addr1.address, amount)).to.not.be.reverted;
    });

    it("应该能够放弃所有权", async function () {
      await expect(this.token.renounceOwnership()).to.not.be.reverted;
      expect(await this.token.owner()).to.equal(ethers.ZeroAddress);
    });

    it("非拥有者不应该能够转移所有权", async function () {
      await expect(this.token.connect(this.addr1).transferOwnership(this.addr1.address))
        .to.be.revertedWithCustomError(this.token, "OwnableUnauthorizedAccount")
        .withArgs(this.addr1.address);
    });
  });
});
