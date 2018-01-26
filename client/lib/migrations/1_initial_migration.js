let Naze = artifacts.require("./../contracts/Naze.sol");

module.exports = function(deployer) {
  deployer.deploy(Naze);
};
