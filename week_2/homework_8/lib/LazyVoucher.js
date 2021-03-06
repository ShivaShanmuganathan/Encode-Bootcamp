const ethers = require('ethers')

// These constants must match the ones used in the smart contract.
const SIGNING_DOMAIN_NAME = "Lazy-Voucher"
const SIGNING_DOMAIN_VERSION = "1"


class LazyVoucher {

  /**
   * Create a new LazyVoucher targeting a deployed instance of the LazyNFT contract.
   * 
   * @param {Object} options
   * @param {ethers.Contract} contract an ethers Contract that's wired up to the deployed contract
   * @param {ethers.Signer} signer a Signer whose account is authorized to mint NFTs on the deployed contract
   */
   
  
  constructor({ contract, signer }) {
    this.contract = contract
    this.signer = signer
    // console.log("Contract Address", this.contract);
    // console.log("Signer Address", this.signer.address);
  }

  /**
   * Creates a new NFTVoucher object and signs it using this LazyVoucher's signing key.
   * 
   * @param {ethers.BigNumber | number} tier the tier of the address
   * @param {address} user the whitelist user address
   * 
   * @returns {Voucher}
   */
  async createVoucher(tier, user) {
    const voucher = { tier, user }
    // console.log("Contract", this.contract.address)
    const domain = await this._signingDomain()
    const types = {
      Voucher: [
        {name: "tier", type: "uint8"},
        {name: "user", type: "address"},
      ]
    }
    const signature = await this.signer._signTypedData(domain, types, voucher)
    return {
      ...voucher,
      signature,
    }
  }

  /**
   * @private
   * @returns {object} the EIP-721 signing domain, tied to the chainId of the signer
   */
  async _signingDomain() {
    if (this._domain != null) {
      return this._domain
    }

    const chainId = await this.contract.getChainID()
    
    this._domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: this.contract.address,
      chainId,
    }
    return this._domain
  }
}

module.exports = {
    LazyVoucher
}