// SPDX-License-Identifier: MIT

// HARDHAT GAS REPORT
// ·--------------------------------------|----------------------------|-------------|-----------------------------·
// |         Solc version: 0.8.4          ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
// ·······································|····························|·············|······························
// |  Methods                             ·               21 gwei/gas                ·       2650.41 usd/eth       │
// ····················|··················|··············|·············|·············|···············|··············
// |  Contract         ·  Method          ·  Min         ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  downvote        ·       38020  ·      55120  ·      42059  ·            5  ·       2.34  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  setVote         ·           -  ·          -  ·      33480  ·            1  ·       1.86  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Proposal         ·  upvote          ·       37998  ·      55098  ·      46548  ·            2  ·       2.59  │
// ····················|··················|··············|·············|·············|···············|··············
// |  ProposalFactory  ·  createProposal  ·           -  ·          -  ·     253299  ·            1  ·      14.10  │
// ····················|··················|··············|·············|·············|···············|··············
// |  Deployments                         ·                                          ·  % of limit   ·             │
// ·······································|··············|·············|·············|···············|··············
// |  ProposalFactory                     ·           -  ·          -  ·    1663086  ·        5.5 %  ·      92.57  │
// ·--------------------------------------|--------------|-------------|-------------|---------------|-------------·


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


