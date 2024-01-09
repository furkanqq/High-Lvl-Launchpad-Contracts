require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {},
    kovan: {
      url: "https://kovan.infura.io/v3/46e5f1638bb04dd4abb7f75bfd4f8898",
      accounts: [process.env.privateKey],
      chainId: 42, // Chain ID should be a number
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      gasPrice: 35000000000,
      skipDryRun: true,
    },
    testBSC: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [process.env.privateKey],
      chainId: 97,
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      skipDryRun: true,
    },
    BSC: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: [process.env.privateKey],
      chainId: 56,
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      skipDryRun: true,
    },
    AvaxTestnet: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [process.env.privateKey],
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      chainId: 43114,
      gasPrice: 22500000000,
      skipDryRun: true,
    },
    ETH: {
      url: "https://mainnet.infura.io/v3/46e5f1638bb04dd4abb7f75bfd4f8898",
      accounts: [process.env.privateKey],
      chainId: 1,
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      gasPrice: 22000000000,
      skipDryRun: true,
    },
    Fantom: {
      url: "https://rpc.fantom.network/",
      accounts: [process.env.privateKey],
      chainId: 250,
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      gasPrice: 52000000000,
      skipDryRun: true,
    },
    testFantom: {
      url: "https://rpc.testnet.fantom.network/",
      accounts: [process.env.privateKey],
      chainId: 4002,
      from: "0x355b3cA2B5e8eA04e65C41b0EA73a88C4f39AC9a",
      skipDryRun: true,
    },
  },
  bscscan: {
    apiKey: "QTU498KHG8T1HHQQKDFKA82D2DUZ54R3U3",
  },
  solidity: {
    version: "0.6.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 20,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    color: true,
    timeout: 40000,
  },
};
