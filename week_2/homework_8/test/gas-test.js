const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256")
const { LazyVoucher } = require('../lib')


async function deploy() {
  [owner, addr1, addr2, addr3] = await ethers.getSigners();

  let factory = await ethers.getContractFactory("GasContract")
  let admins = [
    "0x3243Ed9fdCDE2345890DDEAf6b083CA4cF0F68f2",
    "0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46",
    "0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf",
    "0xeadb3d065f8d15cc05e92594523516aD36d1c834",
    owner.address,
  ];
  const contract = await factory.deploy(admins, 10000)
  // await gasContract.deployed();
  // the redeemerContract is an instance of the contract that's wired up to the redeemer's signing key

  return {
    contract
  }
}

describe("Gas1", function () {
  let gasContract;
  let owner, addr1, addr2, addr3;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const Gas1 = await ethers.getContractFactory("GasContract");
    let admins = [
      "0x3243Ed9fdCDE2345890DDEAf6b083CA4cF0F68f2",
      "0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46",
      "0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf",
      "0xeadb3d065f8d15cc05e92594523516aD36d1c834",
      owner.address,
    ];
    gasContract = await Gas1.deploy(admins, 10000);
    await gasContract.deployed();
  });


  it("Check that admins have been added", async function () {
    
    expect((await gasContract.admins("0x3243Ed9fdCDE2345890DDEAf6b083CA4cF0F68f2")).toString()).to.equal(
      "true"
    );
    expect((await gasContract.admins("0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46")).toString()).to.equal(
      "true"
    );
    expect((await gasContract.admins("0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf")).toString()).to.equal(
      "true"
    );
    expect((await gasContract.admins("0xeadb3d065f8d15cc05e92594523516aD36d1c834")).toString()).to.equal(
      "true"
    );
    expect((await gasContract.admins(owner.address)).toString()).to.equal(
      "true"
    );
    // expect(await gasContract.administrators(1)).to.equal(
    //   "0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46"
    // );
    // expect(await gasContract.administrators(2)).to.equal(
    //   "0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf"
    // );
    // expect(await gasContract.administrators(3)).to.equal(
    //   "0xeadb3d065f8d15cc05e92594523516aD36d1c834"
    // );
    // expect(await gasContract.administrators(4)).to.equal(owner.address);
  });
  it("Checks that the total supply is 10000", async function () {
    let supply = await gasContract.totalSupply();
    expect(supply).to.equal(10000);
  });
  it("Checks a transfer", async function () {
    // owner has total supply, transfer 100

    const transferTx = await gasContract.transfer(addr1.address, 100, "acc1");
    await transferTx.wait();
    let acc1Balance = await gasContract.balanceOf(addr1.address);
    expect(acc1Balance).to.equal(100);
  });

  it("Checks an update", async function () {
    // create a transfer then update

    const transferTx1 = await gasContract.transfer(addr1.address, 300, "acc1");
    await transferTx1.wait();
    const transferTx2 = await gasContract.transfer(addr1.address, 200, "acc1");
    await transferTx2.wait();
    const transferTx3 = await gasContract.transfer(addr1.address, 100, "acc1");
    await transferTx3.wait();
    const transferTx4 = await gasContract.transfer(addr2.address, 300, "acc2");
    await transferTx4.wait();
    const transferTx5 = await gasContract.transfer(addr2.address, 100, "acc2");
    await transferTx5.wait();
    let acc1Balance = await gasContract.balanceOf(addr1.address);
    expect(acc1Balance).to.equal(600);
    let acc2Balance = await gasContract.balanceOf(addr2.address);
    expect(acc2Balance).to.equal(400);
    const updateTx = await gasContract.updatePayment(owner.address, 1, 302, 3);
    await updateTx.wait();
    // now need to check the update
    const Payments = await gasContract.getPayments(owner.address);

    expect(Payments.length).to.equal(5);
    expect(Payments[0].amount).to.equal(302);
    expect(Payments[0].paymentType).to.equal(3);
  });

  it("Checks for events", async function () {
    // create a transfer then update
    await expect(gasContract.transfer(addr1.address, 300, "acc1"))
      .to.emit(gasContract, "Transfer")
      .withArgs(addr1.address, 300);
  });

  it("Checks for admin", async function () {
    await expect(
      gasContract.connect(addr1).updatePayment(owner.address, 1, 302, 3)
    ).to.be.reverted;
  });
  it("Ensure trading mode is set", async function () {
    let mode = await gasContract.getTradingMode();
    expect(mode).to.equal(true);
  });

  //CAN BE adjusted to a level
  it("add users to whitelist and validate key users are added with correct tier", async function () {
    
    const { contract} = await deploy();
    await addToWhitelist(contract);
    
    let whitelist1 = await contract.connect(addr1).checkWhitelist(voucher1);
    expect(parseInt(whitelist1)).to.equal(1);
    let whitelist2 = await contract.connect(addr2).checkWhitelist(voucher2);
    expect(parseInt(whitelist2)).to.equal(2);
    let whitelist3 = await contract.connect(addr3).checkWhitelist(voucher3);
    expect(parseInt(whitelist3)).to.equal(3);

  });

  it("whitelist transfer works", async function () {

    const {contract} = await deploy();
    await addToWhitelist(contract);

    const transferTx1 = await contract.transfer(addr1.address, 500, "acc1");
    await transferTx1.wait();
    const transferTx2 = await contract.transfer(addr2.address, 300, "acc2");
    await transferTx2.wait();
    const transferTx3 = await contract.transfer(addr3.address, 100, "acc2");
    await transferTx3.wait();
    let recipient1 = ethers.Wallet.createRandom();
    let recipient2 = ethers.Wallet.createRandom();
    let recipient3 = ethers.Wallet.createRandom();
    let sendValue1 = 250;
    let sendValue2 = 150;
    let sendValue3 = 50;
    const whiteTransferTx1 = await contract
      .connect(addr1)
      .whiteTransfer(recipient1.address, sendValue1, voucher1);
    await whiteTransferTx1.wait();
    const whiteTransferTx2 = await contract
      .connect(addr2)
      .whiteTransfer(recipient2.address, sendValue2, voucher2);
    await whiteTransferTx2.wait();
    const whiteTransferTx3 = await contract
      .connect(addr3)
      .whiteTransfer(recipient3.address, sendValue3, voucher3);
    await whiteTransferTx3.wait();
    let rec1Balance = await contract.balanceOf(recipient1.address);
    let rec2Balance = await contract.balanceOf(recipient2.address);
    let rec3Balance = await contract.balanceOf(recipient3.address);
    console.log("rec1 Balance",rec1Balance);
    expect(sendValue1 - 1).to.equal(rec1Balance);
    expect(sendValue2 - 2).to.equal(rec2Balance);
    expect(sendValue3 - 3).to.equal(rec3Balance);
    let acc1Balance = await contract.balanceOf(addr1.address);
    let acc2Balance = await contract.balanceOf(addr2.address);
    let acc3Balance = await contract.balanceOf(addr3.address);
    expect(sendValue1 + 1).to.equal(acc1Balance);
    expect(sendValue2 + 2).to.equal(acc2Balance);
    expect(sendValue3 + 3).to.equal(acc3Balance);
  });

  async function addToWhitelist(contract) {
    let addrArray1 = [];
    let addrArray2 = [];
    let addrArray3 = [];
    
    for (let i = 0; i < 9; i++) {
      let wallet = ethers.Wallet.createRandom();
      const lazyVoucher = new LazyVoucher({ contract, signer: owner })
      const voucher = await lazyVoucher.createVoucher(1, wallet.address)
      addrArray1.push(wallet.address);
    }
    const lazyVoucher = new LazyVoucher({ contract, signer: owner })
    voucher1 = await lazyVoucher.createVoucher(1, addr1.address)
    addrArray1.push(addr1.address);

    for (let i = 0; i < 19; i++) {
      let wallet = ethers.Wallet.createRandom();
      const lazyVoucher = new LazyVoucher({ contract, signer: owner })
      const voucher = await lazyVoucher.createVoucher(2, wallet.address)
      addrArray2.push(wallet.address);
    }
    const lazyVoucher2 = new LazyVoucher({ contract, signer: owner })
    voucher2 = await lazyVoucher.createVoucher(2, addr2.address)    
    addrArray2.push(addr2.address);

    for (let i = 0; i < 29; i++) {
      let wallet = ethers.Wallet.createRandom();
      const lazyVoucher = new LazyVoucher({ contract, signer: owner })
      const voucher = await lazyVoucher.createVoucher(3, wallet.address)
      addrArray3.push(wallet.address);
    }
    const lazyVoucher3 = new LazyVoucher({ contract, signer: owner })
    voucher3 = await lazyVoucher.createVoucher(3, addr3.address)    
    addrArray3.push(addr3.address);

    // addrArray4 = addrArray1.concat(addrArray2, addrArray3); 

    // tierArray1 = Array(addrArray1.length).fill(1);
    // tierArray2 = Array(addrArray2.length).fill(2);
    // tierArray3 = Array(addrArray3.length).fill(3);

    // tierArray4 = tierArray1.concat(tierArray2, tierArray3);

    // merkleTree = new MerkleTree(
    //   addrArray4,
    //   keccak256,
    //   { hashLeaves: true, sortPairs: true }
    // )

    // const root = merkleTree.getHexRoot();
    

    // let tx0 = await gasContract.addToWhitelist(root, addrArray4, tierArray4);
    // await tx0.wait();
    // addrArray1.forEach(async (element) => {
    //   let tx1 = await gasContract.addToWhitelist(element, 1);
    //   await tx1.wait();
    // });

    // for (let i = 0; i < 19; i++) {
    //   let wallet = ethers.Wallet.createRandom();
    //   addrArray2.push(wallet.address);
    // }
    // addrArray2.push(addr2.address);
    // addrArray2.forEach(async (element) => {
    //   let tx2 = await gasContract.addToWhitelist(element, 2);
    //   await tx2.wait();
    // });
    // for (let i = 0; i < 29; i++) {
    //   let wallet = ethers.Wallet.createRandom();
    //   addrArray3.push(wallet.address);
    // }
    // addrArray3.push(addr3.address);
    // addrArray3.forEach(async (element) => {
    //   let tx3 = await gasContract.addToWhitelist(element, 3);
    //   await tx3.wait();
    // });
  }
});