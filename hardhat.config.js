require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    ropsten: {
      url: "https://ropsten.infura.io/v3/40c2813049e44ec79cb4d7e0d18de173",
      accounts: [
        "796e2930429e8606d9b4e3a635b649e31909413245097056d87bab9ae3bf098c",
      ],
    },
  },
};
