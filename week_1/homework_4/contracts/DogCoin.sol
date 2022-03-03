// SPDX-License-Identifier: MIT

// SOLIDITY-COVERAGE
// --------------|----------|----------|----------|----------|----------------|
// File          |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
// --------------|----------|----------|----------|----------|----------------|
//  contracts/   |    97.22 |       70 |      100 |     97.3 |                |
//   DogCoin.sol |    97.22 |       70 |      100 |     97.3 |             99 |
// --------------|----------|----------|----------|----------|----------------|
// All files     |    97.22 |       70 |      100 |     97.3 |                |
// --------------|----------|----------|----------|----------|----------------|

// NEW-SOLIDITY-IMPLEMENTATION
// ·-----------------------------|----------------------------|-------------|-----------------------------·
// |     Solc version: 0.8.4     ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
// ······························|····························|·············|······························
// |  Methods                                                                                             │
// ·············|················|·············|··············|·············|···············|··············
// |  Contract  ·  Method        ·  Min        ·  Max         ·  Avg        ·  # calls      ·  usd (avg)  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  approve       ·          -  ·           -  ·      46904  ·            1  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  mint          ·      37152  ·      120265  ·      86857  ·            6  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  transfer      ·      93002  ·      103775  ·      97311  ·            5  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  transferFrom  ·          -  ·           -  ·      41037  ·            2  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  Deployments                ·                                          ·  % of limit   ·             │
// ······························|·············|··············|·············|···············|··············
// |  DogCoin                    ·          -  ·           -  ·    1797349  ·          6 %  ·          -  │
// ·-----------------------------|-------------|--------------|-------------|---------------|-------------·

// OLD-SOLIDITY-IMPLEMENTATION
// ·-----------------------------|----------------------------|-------------|-----------------------------·
// |     Solc version: 0.8.4     ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
// ······························|····························|·············|······························
// |  Methods                                                                                             │
// ·············|················|·············|··············|·············|···············|··············
// |  Contract  ·  Method        ·  Min        ·  Max         ·  Avg        ·  # calls      ·  usd (avg)  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  approve       ·          -  ·           -  ·      46904  ·            1  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  mint          ·      42388  ·      114911  ·      80213  ·            6  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  transfer      ·      68260  ·       87333  ·      75889  ·            5  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  DogCoin   ·  transferFrom  ·          -  ·           -  ·      49976  ·            2  ·          -  │
// ·············|················|·············|··············|·············|···············|··············
// |  Deployments                ·                                          ·  % of limit   ·             │
// ······························|·············|··············|·············|···············|··············
// |  DogCoin                    ·          -  ·           -  ·    1738007  ·        5.8 %  ·          -  │
// ·-----------------------------|-------------|--------------|-------------|---------------|-------------·

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract DogCoin is ERC20 {
    
    address[] public holders;
    mapping (address => uint) public holderIndex;
    
    
    event User_Removed(address user);
    event User_Added(address user);


    constructor() ERC20("DogCoin", "DC") {
        holders.push(address(0));
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);

        if(holderIndex[to] == 0) {
            holders.push(to);
            holderIndex[to] = holders.length - 1;
            emit User_Added(to);
        }

        // bool address_found = false;
        
        // for (uint i = 0; i < holders.length; i++) {
        
        //     if(holders[i] == to){

        //         address_found = true;

        //     }    
        // }

        // if (!address_found){

        //     holders.push(to);
        //     holderIndex[to] = holders.length - 1;
        //     emit User_Added(to);

        // }

    }

    function getHolders() public view returns (address[] memory) {
        
        return holders;

    }

    function _transfer(address from, address to, uint256 amount) internal virtual override{

        super._transfer(from, to, amount);

        if(balanceOf(from) == 0){

            holders[holderIndex[from]] = holders[holders.length - 1];
            holderIndex[holders[holders.length - 1]] = holderIndex[from];
            holders.pop();
            holderIndex[from] = 0;
            emit User_Removed(from);

        }

        if(holderIndex[to] == 0) {
            holders.push(to);
            holderIndex[to] = holders.length - 1;
            emit User_Added(to);
        }


        
        // for (uint i = 0; i < holders.length; i++) {

        //     if(holders[i] == from){

        //         if (balanceOf(from) == 0) {

        //             holders[i] = holders[holders.length - 1];
        //             holders.pop();
        //             holderIndex[from] = i;
        //             emit User_Removed(from);

        //         }

        //     }
        
        //     if(holders[i] == to){

        //         address_found = true;

        //     }    
        // }

        // if (!address_found){

        //     holders.push(to);
        //     holderIndex[to] = holders.length - 1;
        //     emit User_Added(to);

        // }
        
    }


}