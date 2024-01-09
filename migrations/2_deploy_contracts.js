const ERC20Basic = artifacts.require("ERC20Basic");
const FeeToken = artifacts.require("FeeToken");
const StakeMaster = artifacts.require("StakeMaster");
const StakingPool = artifacts.require("StakingPool");
const IDOMaster = artifacts.require("IDOMaster");
const IDOCreator = artifacts.require("IDOCreator");
const IDOPool = artifacts.require("IDOPool");
const TierSystem = artifacts.require("TierSystem");
const { toWei, fromWei, toBN } = web3.utils;

let idoMasterContract;

const totalSupply = toWei("10000");
const poolTokenSupply = toWei("10000");
const stakeAmount = toWei("10");
const feeAmount = toWei("0");

const poolDurationInSecunds = 900;
const feeWallet = "0xb58967989C8e878de4D7e78965e066F26B2d9bF4";
const feeToken = "0xA370216CC1e92c654193A6a6Ecd7EBdbF9FEeC3e";
const burnPercent = "0";



module.exports = async (deployer, network, accounts) => {
    
    ////ERC20Burnable _feeToken,
    ////    address _feeWallet,
    ////        uint256 _feeAmount,
    ////            uint256 _burnPercent
    await deployer.deploy(StakeMaster, feeToken, feeWallet, feeAmount, burnPercent);
    stakeMaster = await StakeMaster.deployed();
    console.log("Stake Master address ====> " + stakeMaster.address);

    let startTime = Math.floor(Date.now() / 1000) + 600;
    let finishTime = startTime + poolDurationInSecunds;
    await deployer.deploy(StakingPool, feeToken, feeToken, startTime, finishTime, poolTokenSupply, true);
    stakingPool = await StakingPool.deployed();
    console.log("StakingPool address ====> " + stakingPool.address);

    console.log("approving for stakingPool");
    await feeTokenContract.methods.approve(stakingPool.address, totalSupply);
    console.log("trying extendDuration");
    await stakingPool.methods.extendDuration(poolTokenSupply);
    console.log("extendDuration");
    
};
