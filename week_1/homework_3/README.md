# Proposal Factory Contract

This project contains a proposal factory contract, which is used to create proposal [voting] contract -- this contract follows the state machine pattern to transition from PROPOSAL to VOTING to ACCEPTED/REJECTED phases.

Unit tests are written for that contract
1. Should Deploy Proposal Factory & Create New Proposal Contract
2. Should return description of proposal in the new proposal contract
3. Should check the proposer of the new proposal contract
4. Should set voting in the new proposal contract
5. Should upvote in the new proposal contract
6. Should downvote in the new proposal contract
7. Should upvote/downvote in the new proposal contract & move to ACCEPTED/REJECTED status

# Clone This Repo & Run This Project


### Clone Repo & Change to project directory
```shell
git clone https://github.com/ShivaShanmuganathan/Encode-Bootcamp.git
cd Encode-Bootcamp/week_1/homework_3
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

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
