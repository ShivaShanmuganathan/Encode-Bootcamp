const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dog Coin Test", function () {
  it("Should return the list of token returns", async function () {
    
    const DogCoin = await ethers.getContractFactory("DogCoin");
    const dog_coin = await DogCoin.deploy();
    await dog_coin.deployed();
    
    [addr1, addr2] = await hre.ethers.getSigners();
    await dog_coin.mint(addr1.address, ethers.utils.parseEther("100"));

    console.log(await dog_coin.getHolders());

    
  });
});
