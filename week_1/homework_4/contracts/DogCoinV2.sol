// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "./DogCoin.sol";
import "hardhat/console.sol";

contract DogCoinV2 is DogCoin {


    string public version;

    function setVersion() external{
        version = "V2";
    }
    
   
    function getVersion() public view returns(string memory){
        return version;
    }
    

}
