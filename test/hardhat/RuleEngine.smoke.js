const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("RuleEngine Hardhat smoke test", function () {
  it("compiles, deploys, and exposes the expected basic state", async function () {
    const [admin] = await ethers.getSigners();

    const RuleEngine = await ethers.getContractFactory("RuleEngine");
    const ruleEngine = await RuleEngine.deploy(
      admin.address,
      ethers.ZeroAddress
    );
    await ruleEngine.waitForDeployment();

    expect(await ruleEngine.version()).to.equal("3.0.0-rc7");
    expect(await ruleEngine.rulesCount()).to.equal(0n);
    expect(await ruleEngine.getTokenBound()).to.equal(ethers.ZeroAddress);

    const defaultAdminRole = await ruleEngine.DEFAULT_ADMIN_ROLE();
    expect(await ruleEngine.hasRole(defaultAdminRole, admin.address)).to.equal(true);
  });

  it("deploys the ERC-2771 variant with its trusted forwarder", async function () {
    const [admin, forwarder] = await ethers.getSigners();

    const RuleEngine2771 = await ethers.getContractFactory("RuleEngine2771");
    const ruleEngine = await RuleEngine2771.deploy(
      admin.address,
      forwarder.address,
      ethers.ZeroAddress
    );
    await ruleEngine.waitForDeployment();

    expect(await ruleEngine.version()).to.equal("3.0.0-rc7");
    expect(await ruleEngine.isTrustedForwarder(forwarder.address)).to.equal(true);

    const defaultAdminRole = await ruleEngine.DEFAULT_ADMIN_ROLE();
    expect(await ruleEngine.hasRole(defaultAdminRole, admin.address)).to.equal(true);
  });
});
