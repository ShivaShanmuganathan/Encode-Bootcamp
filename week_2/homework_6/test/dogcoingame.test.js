const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dog-Coin-Game", function () {
  it("Should deploy Dog-Coin-Game Contract", async function () {
    
    [addr1, addr2, addr3, addr4] = await hre.ethers.getSigners();
    
    
    const DogCoinGame = await ethers.getContractFactory("DogCoinGame");
    dog_coin = await DogCoinGame.deploy();
    await dog_coin.deployed();
    console.log()
    
    console.log("Contract Details")
    console.log("Name of Dog-Coin-Game Contract", await dog_coin.name());
    console.log("Symbol of Dog-Coin-Game Contract", await dog_coin.symbol());
    console.log("Address of Dog-Coin-Game Contract", dog_coin.address);
    console.log()

    console.log("User Addresses")
    console.log("Address 1", addr1.address);
    console.log("Address 2", addr2.address);
    console.log("Address 3", addr3.address);
    console.log("Address 4", addr4.address);
    console.log()
    
  });

  it("Should test addPlayer on Dog-Coin-Game", async function () {
    // 1 ether, 0.1 ether & 10 ether
    await dog_coin.connect(addr1).addPlayer(addr1.address, {value: ethers.utils.parseEther("1")});
    await dog_coin.connect(addr2).addPlayer(addr2.address, {value: ethers.utils.parseEther("0.1")});
    await dog_coin.connect(addr3).addPlayer(addr3.address, {value: ethers.utils.parseEther("10")});

    // 1 wei
    await dog_coin.connect(addr4).addPlayer(addr4.address, {value: ethers.utils.parseEther("0.000000000000000001")});
    
    console.log()
    console.log("Number of players", (await dog_coin.numberPlayers()).toString())
    console.log("Player 0", (await dog_coin.players(0)))
    console.log()

  });


  it("Should loop and add 200 players using addPlayer function ", async function () {

    // 1 wei
    for (let i = 0; i < 198; i++) {
      await dog_coin.connect(addr1).addPlayer(addr1.address, {value: ethers.utils.parseEther("0.000000000000000001")});
    }
    await expect(dog_coin.connect(addr2).addPlayer(addr2.address, {value: ethers.utils.parseEther("0.000000000000000001")})).to.emit(dog_coin, "startPayout");

    console.log()
    console.log("Number of players", (await dog_coin.numberPlayers()).toString())
    console.log("Player 0", (await dog_coin.players(0)))
    console.log("Players 10", (await dog_coin.players(10)))
    console.log("Players 100", (await dog_coin.players(100)))
    console.log("Players 199", (await dog_coin.players(199)))
    console.log()

  });

  it("Should add winners using addWinner function ", async function () {

    await dog_coin.connect(addr1).addWinner(addr1.address);
    await dog_coin.connect(addr1).addWinner(addr4.address);

    console.log("Added Addr1 & Addr4 to Winners List");

  });

  it("Should add winners using addWinner function ", async function () {

    await dog_coin.connect(addr1).addWinner(addr1.address);
    await dog_coin.connect(addr1).addWinner(addr4.address);

    console.log("Added Addr1 & Addr4 to Winners List");

  });

  

  


});

// LOGICAL ERRORS
// 1. There is no require statement to ensure that the payment is received, only if payment is received, the function should allow for state changes.
// 2. Instead of specifying 1 ether, it is specified as just 1, which would only require 1 wei instead of 1 ether
// 3. Anyone can call the winner function, it is public. Anyone can be added to winner list, without any criteria, even the ones who are not players
// 4. The payOut Function logic checks if balance of contract is 100 wei instead of 100 ether
// 5. amountToPay calculation also seems faulty.
// 6. payWinners function is public, so anyone can add themself to winners list and claim the balance of contract
// 7. Compiler warns against usage of send function



