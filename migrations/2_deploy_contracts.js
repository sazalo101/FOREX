const ForexTrading = artifacts.require("ForexTrading");

module.exports = function(deployer) {
  deployer.deploy(ForexTrading);
};
