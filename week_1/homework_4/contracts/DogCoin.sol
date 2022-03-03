// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract DogCoin is ERC20 {
    
    address[] public holders;    
    
    event User_Removed(address user);
    event User_Added(address user);


    constructor() ERC20("DogCoin", "DC") {
        holders.push(address(0));
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);

        // if(holderIndex[to] == 0) {
        //     holders.push(to);
        //     holderIndex[to] = holders.length - 1;
        //     emit User_Added(to);
        // }

        bool address_found = false;
        
        for (uint i = 0; i < holders.length; i++) {
        
            if(holders[i] == to){

                address_found = true;

            }    
        }

        if (!address_found){

            holders.push(to);
            holderIndex[to] = holders.length - 1;
            emit User_Added(to);

        }

    }

    function getHolders() public view returns (address[] memory) {
        
        return holders;

    }

    function _transfer(address from, address to, uint256 amount) internal virtual override{

        super._transfer(from, to, amount);

        // if(balanceOf(from) == 0){

        //     holders[holderIndex[from]] = holders[holders.length - 1];
        //     holderIndex[holders[holders.length - 1]] = holderIndex[from];
        //     holders.pop();
        //     holderIndex[from] = 0;
        //     emit User_Removed(from);

        // }

        // if(holderIndex[to] == 0) {
        //     holders.push(to);
        //     holderIndex[to] = holders.length - 1;
        //     emit User_Added(to);
        // }


        
        for (uint i = 0; i < holders.length; i++) {

            if(holders[i] == from){

                if (balanceOf(from) == 0) {

                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    holderIndex[from] = i;
                    emit User_Removed(from);

                }

            }
        
            if(holders[i] == to){

                address_found = true;

            }    
        }

        if (!address_found){

            holders.push(to);
            holderIndex[to] = holders.length - 1;
            emit User_Added(to);

        }
        
    }


}