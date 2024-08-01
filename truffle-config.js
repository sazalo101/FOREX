const path = require('path');
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const { MNEMONIC } = process.env;

module.exports = {
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    alfajores: {
      provider: () => new HDWalletProvider({
        mnemonic: MNEMONIC,
        providerOrUrl: 'https://alfajores-forno.celo-testnet.org'
      }),
      network_id: 44787, // Celo Alfajores testnet id
      gas: 2000000, // Adjust as needed
      gasPrice: 5000000000 // Adjust as needed
    },
  },
  compilers: {
    solc: {
      version: "0.8.0", // Ensure this matches the version of Solidity used in your contract
    },
  },
  // Optionally enable this to avoid issues with specific network configurations
  // solc: {
  //   optimizer: {
  //     enabled: true,
  //     runs: 200
  //   }
  // }
};
