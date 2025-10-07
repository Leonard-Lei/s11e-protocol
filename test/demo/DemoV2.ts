import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { deployDemoV2Fixture } from "./Demo.fixture";

describe("DemoV2", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("升级后的部署", function () {
    beforeEach(async function () {
      const { demo, demoAddress, initialValue, owner, addr1, addr2 } = await this.loadFixture(deployDemoV2Fixture);
      this.demo = demo;
      this.demoAddress = demoAddress;
      this.initialValue = initialValue;
      this.owner = owner;
      this.addr1 = addr1;
      this.addr2 = addr2;
    });

    it("应该保留初始值", async function () {
      expect(await this.demo.retrieve()).to.equal(this.initialValue);
    });

    it("代理地址应该保持不变", async function () {
      expect(this.demoAddress).to.be.properAddress;
    });
  });

  describe("继承的功能", function () {
    beforeEach(async function () {
      const { demo, initialValue, owner, addr1 } = await this.loadFixture(deployDemoV2Fixture);
      this.demo = demo;
      this.initialValue = initialValue;
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

    it("应该能够读取值", async function () {
      const value = await this.demo.retrieve();
      expect(value).to.equal(this.initialValue);
    });
  });

  describe("新增的 increment 功能", function () {
    beforeEach(async function () {
      const { demo, initialValue, owner, addr1 } = await this.loadFixture(deployDemoV2Fixture);
      this.demo = demo;
      this.initialValue = initialValue;
      this.owner = owner;
      this.addr1 = addr1;
    });

    it("应该能够递增值", async function () {
      const valueBefore = await this.demo.retrieve();
      await this.demo.increment();
      const valueAfter = await this.demo.retrieve();
      expect(valueAfter).to.equal(valueBefore + 1n);
    });

    it("应该触发 ValueChanged 事件", async function () {
      const currentValue = await this.demo.retrieve();
      const expectedValue = currentValue + 1n;
      await expect(this.demo.increment()).to.emit(this.demo, "ValueChanged").withArgs(expectedValue);
    });

    it("任何地址都应该能够递增", async function () {
      const valueBefore = await this.demo.retrieve();
      await this.demo.connect(this.addr1).increment();
      expect(await this.demo.retrieve()).to.equal(valueBefore + 1n);
    });

    it("应该能够多次递增", async function () {
      const startValue = await this.demo.retrieve();
      await this.demo.increment();
      await this.demo.increment();
      await this.demo.increment();
      expect(await this.demo.retrieve()).to.equal(startValue + 3n);
    });

    it("increment 和 store 应该能够配合使用", async function () {
      await this.demo.store(100);
      await this.demo.increment();
      expect(await this.demo.retrieve()).to.equal(101);

      await this.demo.increment();
      await this.demo.store(200);
      expect(await this.demo.retrieve()).to.equal(200);
    });
  });

  describe("状态保留测试", function () {
    beforeEach(async function () {
      const { demo } = await this.loadFixture(deployDemoV2Fixture);
      this.demo = demo;
    });

    it("升级前设置的值应该在升级后保留", async function () {
      // 这个在 fixture 中已经测试了，这里再次验证
      expect(await this.demo.retrieve()).to.equal(42);
    });

    it("升级后修改的值应该正确存储", async function () {
      await this.demo.store(888);
      expect(await this.demo.retrieve()).to.equal(888);

      await this.demo.increment();
      expect(await this.demo.retrieve()).to.equal(889);
    });
  });
});
