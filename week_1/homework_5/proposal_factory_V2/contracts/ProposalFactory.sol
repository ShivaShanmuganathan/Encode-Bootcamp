// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Proposal.sol";

pragma solidity ^0.8.0;

contract ProposalFactory {
    address immutable tokenImplementation;
    address[] public deployedProposals;

    constructor() public {
        tokenImplementation = address(new Proposal());
    }

    function createProposal(uint _minimum, string calldata _description, uint _expiryTime) public returns (address){
        address clone = Clones.clone(tokenImplementation);
        Proposal(clone).initialize(_minimum, _description, _expiryTime, address(msg.sender));
        // Proposal newProposal = new Proposal(_minimum, _description, _expiryTime, address(msg.sender));
        deployedProposals.push(clone);
        return clone;
    }

    function getDeployedProposals() public view returns (address[] memory) {
        return deployedProposals;
    }
}


