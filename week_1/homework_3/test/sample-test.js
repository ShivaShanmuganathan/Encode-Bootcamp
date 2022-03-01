const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Proposal Factory", function () {

  before(async function () {

    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();          

  });
  
  it("Should Deploy Proposal Factory & Create New Proposal Contracts", async function () {
    
    const ProposalFactory = await ethers.getContractFactory("ProposalFactory");
    const Proposal = await ethers.getContractFactory("Proposal");
    
    const proposal_factory = await ProposalFactory.deploy();
    await proposal_factory.deployed();
    

    proposal = await proposal_factory.createProposal(3, "Hello World Is Awesome", Math.floor(Date.now() / 1000 + 3600));

    console.log("Deployed Proposal Address", await proposal_factory.getDeployedProposals());
    proposed_contract = await Proposal.attach((await proposal_factory.getDeployedProposals())[0]);
    
  });


});
