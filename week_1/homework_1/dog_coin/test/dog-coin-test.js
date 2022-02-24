const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dog Coin Test", function () {

  it("Should return the list of token returns", async function () {
    
    const DogCoin = await ethers.getContractFactory("DogCoin");
    const dog_coin = await DogCoin.deploy();
    await dog_coin.deployed();
    
    [addr1, addr2] = await hre.ethers.getSigners();
    
    await dog_coin.mint(addr1.address, ethers.utils.parseEther("100"));

    await dog_coin.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("50"));
    
    console.log("Balance of Sender", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr1.address))));
    console.log("Balance of Receiver", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr2.address))));

    console.log(await dog_coin.getHolders());
    console.log(addr1.address);
    console.log(addr2.address);
    

  });
});
