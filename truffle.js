const HDWalletProvider = require("@truffle/hdwallet-provider");
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "172.20.15.167",
      port: 8545,
      network_id: "*", // Match any network id
    },
    goerli: {
      provider: () =>
        new HDWalletProvider({
          privateKeys:
            "e3a599c28e6f03fecc4a46305de3829a939498eec12d651a32beba736414cee4",
          providerOrUrl:
            "https://rinkeby.infura.io/v3/9367ac3f938f4d6083e6211e05844435", //从infura网站获取
          numberOfAddress: 2,
        }),
      network_id: 5, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },
  },
};
