//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Assembly {
    

    // Defining function
	function returnEth() public payable returns (uint a) {
        uint value = msg.value;
		// Inline assembly code
		assembly {

            let x := mload(0x40) // get empty storage location
            mstore ( x, value )
            a := x
			
		}
	}
}



