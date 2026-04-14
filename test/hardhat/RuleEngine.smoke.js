const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("RuleEngine Hardhat smoke test", function () {
  it("compiles, deploys, and exposes the expected basic state", async function () {
    const [admin] = await ethers.getSigners();

    const RuleEngine = await ethers.getContractFactory("RuleEngine");
    const ruleEngine = await RuleEngine.deploy(
      admin.address,
      ethers.ZeroAddress,
      ethers.ZeroAddress
    );
    await ruleEngine.waitForDeployment();

    expect(await ruleEngine.version()).to.equal("3.0.0");
    expect(await ruleEngine.rulesCount()).to.equal(0n);
    expect(await ruleEngine.getTokenBound()).to.equal(ethers.ZeroAddress);

    const defaultAdminRole = await ruleEngine.DEFAULT_ADMIN_ROLE();
    expect(await ruleEngine.hasRole(defaultAdminRole, admin.address)).to.equal(true);
  });
});
