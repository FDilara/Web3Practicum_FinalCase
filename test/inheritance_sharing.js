const InheritanceSharing = artifacts.require("../contracts/InheritanceSharing");
const InheritanceToken = artifacts.require("../contracts/InheritanceToken");

var inheritanceSharingIntance;
var inheritanceTokenIntance;

contract("InheritanceSharing", (accounts) => {
    it("deploying task", async () => {
      inheritanceSharingIntance = await InheritanceSharing.deployed();
      inheritanceTokenIntance = await InheritanceToken.deployed();
      await inheritanceTokenIntance.mintToAddress(accounts[0]);
      const balance = await inheritanceTokenIntance.getBalance(accounts[0]);
    
      assert.equal(balance.valueOf(), 100000000000000000000000, "10000 wasn't in the first account");
    });   
    it("approving task", async () => {
      await inheritanceTokenIntance.approve(inheritanceSharingIntance.address, await inheritanceTokenIntance.balanceOf(accounts[0]).valueOf(), { from: accounts[0] });
    });   
    it("publish testament task", async () => {
      await inheritanceSharingIntance.publishTestament(inheritanceTokenIntance.address, [accounts[1]], 0, await inheritanceTokenIntance.balanceOf(accounts[0]).valueOf(), { from: accounts[0] });
    });
    it("proof to death task", async () => {
      await inheritanceSharingIntance.proofToDeath(accounts[0], accounts[1], { from: accounts[1] });

      assert.equal(await inheritanceSharingIntance.died(accounts[0]), true, "did not die");
    });
    it("receipt inheritance task", async () => {
      await inheritanceSharingIntance.receiptToTestament(accounts[0], accounts[1], { from: accounts[1] });

      assert.equal(await inheritanceSharingIntance.receipt(accounts[0], accounts[1]), true, "no receipt inheritance");
    });   
    
});