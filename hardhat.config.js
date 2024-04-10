/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-foundry");
require('solidity-docgen');
module.exports = {
  solidity: "0.8.22",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    evmVersion:"london"
  }
};
