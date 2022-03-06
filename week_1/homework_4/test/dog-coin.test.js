const { ethers, upgrades } = require('hardhat');
const { expect } = require("chai");

describe('Dog Coin', function () {
  it('Deploys Dog Coin', async function () {
    const DogCoinV1 = await ethers.getContractFactory('DogCoin');

    dog_coin_v1 = await upgrades.deployProxy(DogCoinV1, { kind: 'uups' });

    const DogCoinV2 = await ethers.getContractFactory('DogCoinV2');

    dog_coin_v2 = await upgrades.upgradeProxy(dog_coin_v1.address, DogCoinV2);

    [addr1, addr2, addr3, addr4] = await hre.ethers.getSigners();

    console.log("Address 1", addr1.address);
    console.log("Address 2", addr2.address);
    console.log("Address 3", addr3.address);
    console.log("Address 4", addr4.address);
        
    await expect(dog_coin_v2.connect(addr1).mint(addr1.address, ethers.utils.parseEther("100"))).to.emit(dog_coin_v2, "UserAdded").withArgs(addr1.address);
    await expect(dog_coin_v2.connect(addr3).mint(addr3.address, ethers.utils.parseEther("100"))).to.emit(dog_coin_v2, "UserAdded").withArgs(addr3.address);
    
    await expect(dog_coin_v2.connect(addr1).mint(addr1.address, ethers.utils.parseEther("100"))).to.not.emit(dog_coin_v2, "UserAdded").withArgs(addr1.address);
    
    await expect(dog_coin_v2.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("50"))).to.emit(dog_coin_v2, "UserAdded").withArgs(addr2.address);
    
    await dog_coin_v2.connect(addr1).approve(addr2.address, ethers.utils.parseEther("10"));
    
    console.log("Allowance Of", parseFloat(ethers.utils.formatEther(await dog_coin_v2.connect(addr2).allowance(addr1.address, addr2.address))));
    
    await expect(dog_coin_v2.connect(addr2).transferFrom(addr1.address, addr2.address, ethers.utils.parseEther("10"))).to.not.emit(dog_coin_v2, "UserAdded").withArgs(addr2.address);

    await expect(dog_coin_v2.connect(addr3).transfer(addr4.address, ethers.utils.parseEther("100"))).to.emit(dog_coin_v2, "UserRemoved").withArgs(addr3.address).to.emit(dog_coin_v2, "UserAdded").withArgs(addr4.address);
    
    console.log("Balance of addr1", parseFloat(ethers.utils.formatEther(await dog_coin_v2.balanceOf(addr1.address))));
    console.log("Balance of addr2", parseFloat(ethers.utils.formatEther(await dog_coin_v2.balanceOf(addr2.address))));
    console.log("Balance of addr3", parseFloat(ethers.utils.formatEther(await dog_coin_v2.balanceOf(addr3.address))));
    console.log("Balance of addr4", parseFloat(ethers.utils.formatEther(await dog_coin_v2.balanceOf(addr4.address))));

    console.log(await dog_coin_v2.getHolders());
    
    expect((await dog_coin_v2.getHolders()).length).to.be.equal(3); 
    expect((await dog_coin_v2.getHolders())[0]).to.be.equal(addr1.address); 
    expect((await dog_coin_v2.getHolders())[1]).to.be.equal(addr2.address); 
    expect((await dog_coin_v2.getHolders())[2]).to.be.equal(addr4.address); 
    
    await dog_coin_v2.setVersion();
    expect((await dog_coin_v2.getVersion()).toString()).to.be.equal("V2"); 

  });
});
