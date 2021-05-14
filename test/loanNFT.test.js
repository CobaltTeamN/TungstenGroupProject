const NFTLoan = artifacts.require("./NFTLoan.sol")

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('NFTLoan', (accounts) => {
    let contract
    
    // Create contract instance
    before(async () => {
    contract = await NFTLoan.deployed()
  })

  // Contract Deploys Successfully
  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address = contract.address
      assert.notEqual(address, 0x0)
      assert.notEqual(address, '')
      assert.notEqual(address, null)
      assert.notEqual(address, undefined)
    })

}
