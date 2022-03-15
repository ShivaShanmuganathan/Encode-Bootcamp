// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";


contract YULContract {

    // YUL: return Amount of Eth sent
    function yul_ret_amount_of_eth() public payable returns (uint) {
        assembly {
            let msgvalue := callvalue()
            mstore(0x0, msgvalue)
            return(0x0, 32)
        }
    }
    
    // Return amount of eth solidity (for testing)
   function sol_ret_amount_of_eth() public payable returns (uint256) {
        return msg.value;
    }

}