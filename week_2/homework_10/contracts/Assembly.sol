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

			// Creating a new variable 'c'
			// Calculate the sum of 'a+16'
			// with the 'add' opcode
			// assign the value to the 'c'
			// let c := msg.value

			// Use 'mstore' opcode to
			// store 'c' in memory
			// at memory address 0x80
			// mstore(0x80, c)
			{

				// Creating a new variable'
				// Calculate the sum of 'sload(c)+12'
				// means values in variable 'c'
			// with the 'add' opcode
			// assign the value to 'd'
				// let d := add(sload(c), 12)

				// assign the value of 'd' to 'b'
				// b := d

			// 'd' is deallocated now
			}
	
			// Calculate the sum of 'b+c' with the 'add' opcode
			// assign the value to 'b'
			// b := add(b, c)

		// 'c' is deallocated here
		}
	}
}



