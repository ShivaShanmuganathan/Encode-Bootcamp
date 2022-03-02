# Encode Expert Solidity Bootcamp

# Dog Coin Explained

- ### The project contains a Dog Coin ERC-20 Contract that maintains an array of its current holders.
- ### New users are added to array, during minting or transferring of Dog Coin.
- ### When user's balance falls to zero, the user is removed from the holders array.
- ### User_Added & User_Removed events are emitted when the user is added or removed from the holders array.

### View [Contract Code](https://ropsten.etherscan.io/address/0x6B9A797cBB62c24B6c61a09802Dc606B9CAe89D6#code) Deployed To [Ropsten Network](https://ropsten.etherscan.io/address/0x6B9A797cBB62c24B6c61a09802Dc606B9CAe89D6)

### Contract Address
``` shell
0x6B9A797cBB62c24B6c61a09802Dc606B9CAe89D6
```



# Clone This Repo & Run This Project


### Clone Repo & Change to project directory
```shell
git clone https://github.com/ShivaShanmuganathan/Encode-Bootcamp.git
cd Encode-Bootcamp/week_1/homework_2/dog_coin
```

### Install Dependencies
```shell
npm install
```

### Compile & Test Smart Contract
```shell
npx hardhat compile
npx hardhat test
```

### Generate Test Coverage For Contract
```shell
npx hardhat coverage
```


# Deploy The Contract & Verify Contract on Etherscan

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
npx hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS
```
