const InheritanceToken = artifacts.require("InheritanceToken");

module.exports = function (deployer) {
  deployer.deploy(InheritanceToken);
};