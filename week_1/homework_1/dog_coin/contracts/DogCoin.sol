// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract DogCoin is ERC20 {
    
    address[] public holders;
    uint[] public holders2;
    
    constructor() ERC20("DogCoin", "DC") {
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
        holders.push(to);
    }

    function getHolders() public view returns (address[] memory) {
        
        return holders;

    }
    


}