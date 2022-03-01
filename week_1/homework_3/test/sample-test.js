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

  it("Should return description of proposal in the new proposal contract", async function () {  

    const return_value = (await proposed_contract.getSummary());
    console.log(return_value.description.toString());

  });

  it("Should check the proposer of the new proposal contract", async function () {  
    
    const return_value = (await proposed_contract.getSummary());
    console.log("Proposer Address", return_value.proposer.toString());
    console.log("Owner Address", owner.address)

  });

  it("Should set voting in the new proposal contract", async function () {  
    // enum returns 1 because VOTING is in 1 position in enum
    await proposed_contract.setVote();
    const return_value = (await proposed_contract.getSummary());
    console.log(return_value.status.toString());

  });


  



});
