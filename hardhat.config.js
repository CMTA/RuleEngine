/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-foundry");
module.exports = {
  solidity: "0.8.33",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    evmVersion:"prague"
  }
};
