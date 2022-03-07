const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dog-Coin-Game", function () {
  it("Should deploy Dog-Coin-Game Contract", async function () {

    const DogCoinGame = await ethers.getContractFactory("DogCoinGame");
    dog_coin = await DogCoinGame.deploy();
    await dog_coin.deployed();
    
    console.log("Name of Dog-Coin-Game Contract", await dog_coin.name());
    console.log("Symbol of Dog-Coin-Game Contract", await dog_coin.symbol());
    console.log("Address of Dog-Coin-Game Contract", dog_coin.address);
    
  });

  it("Should deploy Dog-Coin-Game Contract", async function () {



  });


});
