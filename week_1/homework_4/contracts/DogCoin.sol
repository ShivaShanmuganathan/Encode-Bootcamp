// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


import "hardhat/console.sol";

contract DogCoin is Initializable, ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    
    address[] public holders;
    
    event User_Removed(address user);
    event User_Added(address user);


    function initialize() initializer public {
      __ERC20_init("DogCoin", "DC");
      __Ownable_init();
      __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);

        bool address_found;
        
        for (uint i = 0; i < holders.length; i++) {
        
            if(holders[i] == to){

                address_found = true;

            }    
        }

        if (!address_found){

            holders.push(to);
            emit User_Added(to);

        }

    }

    function getHolders() public view returns (address[] memory) {
        
        return holders;

    }

    function _transfer(address from, address to, uint256 amount) internal virtual override{

        super._transfer(from, to, amount);
        
        bool remove_user;
        bool user_exists;
        
        if (balanceOf(from) == 0) {
            remove_user=true;
        }

        for (uint i = 0; i < holders.length; i++) {

            if(remove_user){

                if(holders[i] == from){

                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    emit User_Removed(from);

                }

            }

            if(holders[i] == to){

                user_exists = true;

            }

        }

        if (!user_exists){

            holders.push(to);
            emit User_Added(to);

        }
    }

}