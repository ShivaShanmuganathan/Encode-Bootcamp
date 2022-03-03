const { ethers, upgrades } = require('hardhat');
const { expect } = require("chai");

describe('Dog Coin', function () {
  it('Deploys Dog Coin', async function () {
    const DogCoinV1 = await ethers.getContractFactory('DogCoin');

    dog_coin_v1 = await upgrades.deployProxy(DogCoinV1, { kind: 'uups' });

    const DogCoinV2 = await ethers.getContractFactory('DogCoinV2');

    await upgrades.upgradeProxy(dog_coin_v1.address, DogCoinV2);

    [addr1, addr2, addr3, addr4] = await hre.ethers.getSigners();
  });
});


// describe("Dog Coin Test", function () {

//   it("Should return the list of token returns", async function () {
    
//     const DogCoin = await ethers.getContractFactory("DogCoin");
//     const dog_coin = await DogCoin.deploy();
//     await dog_coin.deployed();
    
//     [addr1, addr2, addr3, addr4] = await hre.ethers.getSigners();

//     console.log("Address 1", addr1.address);
//     console.log("Address 2", addr2.address);
//     console.log("Address 3", addr3.address);
//     console.log("Address 4", addr4.address);
        
//     await expect(dog_coin.connect(addr1).mint(addr1.address, ethers.utils.parseEther("100"))).to.emit(dog_coin, "User_Added").withArgs(addr1.address);
//     await expect(dog_coin.connect(addr3).mint(addr3.address, ethers.utils.parseEther("100"))).to.emit(dog_coin, "User_Added").withArgs(addr3.address);
    
//     await expect(dog_coin.connect(addr1).mint(addr1.address, ethers.utils.parseEther("100"))).to.not.emit(dog_coin, "User_Added").withArgs(addr1.address);
    
//     await expect(dog_coin.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("50"))).to.emit(dog_coin, "User_Added").withArgs(addr2.address);
    
//     await dog_coin.connect(addr1).approve(addr2.address, ethers.utils.parseEther("10"));
    
//     console.log("Allowance Of", parseFloat(ethers.utils.formatEther(await dog_coin.connect(addr2).allowance(addr1.address, addr2.address))));
    
//     await expect(dog_coin.connect(addr2).transferFrom(addr1.address, addr2.address, ethers.utils.parseEther("10"))).to.not.emit(dog_coin, "User_Added").withArgs(addr2.address);

//     await expect(dog_coin.connect(addr3).transfer(addr4.address, ethers.utils.parseEther("100"))).to.emit(dog_coin, "User_Removed").withArgs(addr3.address).to.emit(dog_coin, "User_Added").withArgs(addr4.address);
    
//     console.log("Balance of addr1", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr1.address))));
//     console.log("Balance of addr2", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr2.address))));
//     console.log("Balance of addr3", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr3.address))));
//     console.log("Balance of addr4", parseFloat(ethers.utils.formatEther(await dog_coin.balanceOf(addr4.address))));

//     console.log(await dog_coin.getHolders());
    
//     expect((await dog_coin.getHolders()).length).to.be.equal(3); 
//     expect((await dog_coin.getHolders())[0]).to.be.equal(addr1.address); 
//     expect((await dog_coin.getHolders())[1]).to.be.equal(addr2.address); 
//     expect((await dog_coin.getHolders())[2]).to.be.equal(addr4.address); 


//   });
// });
