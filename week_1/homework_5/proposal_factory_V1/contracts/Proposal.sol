// SPDX-License-Identifier: MIT

// HARDHAT GAS REPORT
// ·--------------------------------------|----------------------------|-------------|-----------------------------·
// |         Solc version: 0.8.4          ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
// ·······································|····························|·············|······························
// |  Methods                             ·               20 gwei/gas                ·       2642.33 usd/eth       │
// ····················|··················|··············|·············|·············|···············|··············
// |  Contract         ·  Method          ·  Min         ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  downvote        ·       35379  ·      52479  ·      39418  ·            5  ·       2.08  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  setVote         ·           -  ·          -  ·      30794  ·            1  ·       1.63  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  upvote          ·       35357  ·      52457  ·      43907  ·            2  ·       2.32  │
// ····················|··················|··············|·············|·············|···············|··············
// |  ProposalFactory  ·  createProposal  ·           -  ·          -  ·    1033934  ·            1  ·      54.64  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Deployments                         ·                                          ·  % of limit   ·             │
// ·······································|··············|·············|·············|···············|··············
// |  ProposalFactory                     ·           -  ·          -  ·    1543131  ·        5.1 %  ·      81.55  │
// ·--------------------------------------|--------------|-------------|-------------|---------------|-------------·

pragma solidity ^0.8.0;

contract ProposalFactory {
    Proposal[] public deployedProposals;

    function createProposal(uint _minimum, string calldata _description, uint _expiryTime) public returns (Proposal){
        Proposal newProposal = new Proposal(_minimum, _description, _expiryTime, address(msg.sender));
        deployedProposals.push(newProposal);
        return newProposal;
    }

    function getDeployedProposals() public view returns (Proposal[] memory) {
        return deployedProposals;
    }
}

contract Proposal {
    
    struct propose {
        uint256 minimumVotes;
        string description;
        uint256 expiryTime;
        ProposalStatus status;
        address proposer;
        uint256 approvalCount;
        uint256 disApprovalCount;
    }
    propose public proposal;

    address public proposer;
    
    
    enum ProposalStatus {PROPOSED, VOTING, ACCEPTED, REJECTED}


    
    modifier onlyProposer() {
        require(msg.sender == proposer, "Only managers can do this.");
        _;
    }

    constructor (uint _minimum, string memory _description, uint _expiryTime, address _proposer) {

        proposal.minimumVotes = _minimum;
        proposal.description = _description;
        proposal.expiryTime = _expiryTime;
        proposal.status = ProposalStatus.PROPOSED;
        proposal.proposer = _proposer;
        proposal.approvalCount = 0;
        proposal.disApprovalCount = 0;
        proposer = _proposer;
    }

    function setVote() public onlyProposer{

        require(proposal.status == ProposalStatus.PROPOSED, "Proposal is now under voting");
        require(block.timestamp < proposal.expiryTime , "Proposal Time Has Expired");
        proposal.status = ProposalStatus.VOTING;

    }

    function upvote() public {
        require(proposal.status == ProposalStatus.VOTING, "Proposal is now not under voting");
        require(block.timestamp < proposal.expiryTime , "Proposal Time Has Expired");
        
        proposal.approvalCount++;

        if (int(proposal.approvalCount)-int(proposal.disApprovalCount)  >= int(proposal.minimumVotes)){
            proposal.status = ProposalStatus.ACCEPTED;
        }
    }

    function downvote() public {
        
        require(proposal.status == ProposalStatus.VOTING, "Proposal is now not under voting");
        require(block.timestamp < proposal.expiryTime , "Proposal Time Has Expired");

        proposal.disApprovalCount++;

        if (int(proposal.disApprovalCount)-int(proposal.approvalCount)  >= int(proposal.minimumVotes)){
            proposal.status = ProposalStatus.REJECTED;
        }

    }

    function getSummary() public view returns(propose memory){

        return proposal;

    }


    
}