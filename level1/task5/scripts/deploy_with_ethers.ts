import { deploy } from './ethers-lib'

(async () => {
  try {
    const result = await deploy('Bank', ['0x5B38Da6a701c568545dCfcB03FcB875f56beddC4'])
    console.log(`address: ${result.address}`)
  } catch (e) {
    console.log(e.message)
  }
})()