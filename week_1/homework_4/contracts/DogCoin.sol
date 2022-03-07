// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "hardhat/console.sol";

contract DogCoin is Initializable, ERC20Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    
    address[] public holders;
    
    event UserRemoved(address user);
    event UserAdded(address user);


    function initialize() public initializer  {
      __ERC20_init("DogCoin", "DC");
      __Ownable_init();
      __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);

        bool userExists;
        
        for (uint i = 0; i < holders.length; i++) {
        
            if(holders[i] == to){

                userExists = true;

            }    
        }

        if (!userExists){

            holders.push(to);
            emit UserAdded(to);

        }

    }

    function getHolders() public view returns (address[] memory) {
        
        return holders;

    }

    function _transfer(address from, address to, uint256 amount) internal virtual override{

        super._transfer(from, to, amount);
        
        bool removeUser;
        bool userExists;
        
        if (balanceOf(from) == 0) {
            removeUser=true;
        }

        for (uint i = 0; i < holders.length; i++) {

            if(removeUser){

                if(holders[i] == from){

                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    emit UserRemoved(from);

                }

            }

            if(holders[i] == to){

                userExists = true;

            }

        }

        if (!userExists){

            holders.push(to);
            emit UserAdded(to);

        }
    }

}