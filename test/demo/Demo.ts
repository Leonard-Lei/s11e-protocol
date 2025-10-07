import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { upgrades } from "hardhat";

import type { Signers } from "../types";
import { deployDemoFixture } from "./Demo.fixture";

describe("Demo", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("部署", function () {
    beforeEach(async function () {
      const { demo, demoAddress, initialValue, owner, addr1, addr2 } = await this.loadFixture(deployDemoFixture);
      this.demo = demo;
      this.demoAddress = demoAddress;
      this.initialValue = initialValue;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
    });

    it("应该正确初始化值", async function () {
      expect(await this.demo.retrieve()).to.equal(this.initialValue);
    });

    it("应该正确部署代理合约", async function () {
      expect(this.demoAddress).to.be.properAddress;
    });

    it("不应该允许重复初始化", async function () {
      await expect(this.demo.initialize(100)).to.be.revertedWithCustomError(this.demo, "InvalidInitialization");
    });
  });

  describe("存储功能", function () {
    beforeEach(async function () {
      const { demo, owner, addr1 } = await this.loadFixture(deployDemoFixture);
      this.demo = demo;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("应该能够存储新值", async function () {
      const newValue = 123;
      await this.demo.store(newValue);
      expect(await this.demo.retrieve()).to.equal(newValue);
    });

    it("应该触发 ValueChanged 事件", async function () {
      const newValue = 456;
      await expect(this.demo.store(newValue)).to.emit(this.demo, "ValueChanged").withArgs(newValue);
    });

    it("任何地址都应该能够存储值", async function () {
      const newValue = 789;
      await this.demo.connect(this.addr1).store(newValue);
      expect(await this.demo.retrieve()).to.equal(newValue);
    });

    it("应该能够覆盖之前的值", async function () {
      await this.demo.store(100);
      await this.demo.store(200);
      await this.demo.store(300);
      expect(await this.demo.retrieve()).to.equal(300);
    });
  });

  describe("读取功能", function () {
    beforeEach(async function () {
      const { demo, initialValue } = await this.loadFixture(deployDemoFixture);
      this.demo = demo;
      this.initialValue = initialValue;
    });

    it("应该返回当前存储的值", async function () {
      expect(await this.demo.retrieve()).to.equal(this.initialValue);
    });

    it("读取不应该修改状态", async function () {
      const valueBefore = await this.demo.retrieve();
      await this.demo.retrieve();
      const valueAfter = await this.demo.retrieve();
      expect(valueBefore).to.equal(valueAfter);
    });
  });

  describe("可升级性", function () {
    beforeEach(async function () {
      const { demo, demoAddress, initialValue } = await this.loadFixture(deployDemoFixture);
      this.demo = demo;
      this.demoAddress = demoAddress;
      this.initialValue = initialValue;
    });

    it("应该能够升级到 DemoV2", async function () {
      const DemoV2 = await ethers.getContractFactory("DemoV2");
      const upgraded = await upgrades.upgradeProxy(this.demoAddress, DemoV2);
      expect(await upgraded.getAddress()).to.equal(this.demoAddress);
    });

    it("升级后应该保留状态", async function () {
      // 先修改值
      await this.demo.store(999);

      // 升级合约
      const DemoV2 = await ethers.getContractFactory("DemoV2");
      const upgraded = await upgrades.upgradeProxy(this.demoAddress, DemoV2);

      // 验证状态保留
      expect(await upgraded.retrieve()).to.equal(999);
    });

    it("升级后应该有新功能", async function () {
      const DemoV2 = await ethers.getContractFactory("DemoV2");
      const upgraded = await upgrades.upgradeProxy(this.demoAddress, DemoV2);

      // 验证新增的 increment 函数存在
      expect(upgraded.increment).to.exist;
    });
  });
});
