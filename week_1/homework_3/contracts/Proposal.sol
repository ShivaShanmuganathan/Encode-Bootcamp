// SPDX-License-Identifier: MIT
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