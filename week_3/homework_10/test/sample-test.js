const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("YULContract", function () {
  it("Should return the ether sent to the contract once it's changed", async function () {
    const YULContract = await ethers.getContractFactory("YULContract");
    const yulContract = await YULContract.deploy();
    await yulContract.deployed();
    
    await yulContract.sol_ret_amount_of_eth({value: ethers.utils.parseEther("1.0")});
    
    await yulContract.yul_ret_amount_of_eth({value: ethers.utils.parseEther("1.0")});
    

  });
});
