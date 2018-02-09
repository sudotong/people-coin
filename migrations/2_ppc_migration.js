var Rewards = artifacts.require("Rewards");
var Events = artifacts.require("Events");
var PPC = artifacts.require("PPC");

module.exports = function(deployer, network, accounts) {
  // deployment steps
  deployer.deploy([Rewards, Events, PPC]);
  
  var rewards, events, ppc;
  deployer.then(function(){
    return Rewards.deployed()
  }).then(function(instance){
    rewards = instance;
    return Events.deployed()
  }).then(function(instance){
    events = instance;
    return PPC.deployed()
  }).then(function(instance){
    ppc = instance;

    rewards.grantAuthority(accounts[0]);
    events.grantAuthority(accounts[0]);
    ppc.grantAuthority(accounts[0]);
    events.setRewardsContract(rewards.address);
    ppc.setRewardsContract(rewards.address);
    ppc.setEventsContract(events.address);
    return ppc.setPPCWallet("0x10f5125ECEdd1a0c13de969811A8c8Aa2139eCeb");

  })
};