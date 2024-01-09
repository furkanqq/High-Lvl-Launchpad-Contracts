const IDOPool = artifacts.require("IDOPool");
const IDOMaster = artifacts.require("IDOMaster");
let rewardToken;
let idoMasterContract;
let idoPool;

module.exports = async function (deployer, network, accounts) {

    const feeToken = "0xcE01C35b316cCdf43eB3a5f73aA597D519637A28";
    const feeWallet = "0x56655FdfF46Ac28dB72603c5589A69B45B8604cc";
    const feeAmount = "10000000000000000000";
    const burnPercent = "45";

    // constructor(
    //    ERC20Burnable _feeToken,
    //    address _feeWallet,
    //    uint256 _feeAmount,
    //    uint256 _burnPercent
    // )

    await deployer.deploy(IDOMaster, feeToken, feeWallet, feeAmount, burnPercent);
    idoMasterContract = await IDOMaster.deployed();
    console.log("IDO master address ====> " + idoMasterContract.address);


    // uint256 _tokenPrice, 0.000001 ETH
    // address _rewardToken,
    // uint256 _startTimestamp,
    // uint256 _finishTimestamp,
    // uint256 _startClaimTimestamp,
    // uint256 _minEthPayment, 0.001 ETH
    // uint256 _maxEthPayment, 0.1 ETH
    // uint256 _maxDistributedTokenAmount 1000000 dant

    const totalSupply = "1000000000000000000000"; 
    const tokenPrice = "1000000000000000"; 
    const minEthPayment = "100000000000000"; 
    const maxEthPayment = "100000000000000000"; 
    const maxDistributedTokenAmount = totalSupply; 

    await deployer.deploy(ERC20Basic, totalSupply);
    rewardToken = await ERC20Basic.deployed();
    console.log("ITO Token address ====> " + rewardToken.address);
    const rewardToken = await ERC20Basic.at("0x0394d17af9dd20a1330754ca88deda4afa687b34");
};
