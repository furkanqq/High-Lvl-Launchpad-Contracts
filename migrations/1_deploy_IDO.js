const ERC20Basic = artifacts.require("ERC20Basic");
const FeeToken = artifacts.require("FeeToken");
const StakeMaster = artifacts.require("StakeMaster");
const StakingPool = artifacts.require("StakingPool");
const IDOMaster = artifacts.require("IDOMaster");
const FeeProcessor = artifacts.require("FeeProcessor");
const IDOProcessor = artifacts.require("IDOProcessor");
const IDOCreator = artifacts.require("IDOCreator");
const IDOPoolFactory = artifacts.require("IDOPoolFactory");
const IDOPool = artifacts.require("IDOPool");
const TierSystem = artifacts.require("TierSystem");
const { toWei, fromWei, toBN } = web3.utils;

let idoMasterContract;

const totalSupply = toWei("10000");
const poolTokenSupply = toWei("1");
const stakeAmount = toWei("10");
const feeAmount = toWei("0");
const poolDurationInSecunds = 900;

//TestBSC
const feeWallet = "0x6597F132775BBC503a6FC989208Be74435EA6B32";
const feeToken = "0xce01c35b316ccdf43eb3a5f73aa597d519637a28";
const burnPercent = "0";

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(
    TierSystem,
    toWei("100"),
    "100",
    toWei("10"),
    "100",
    toWei("100"),
    "100",
    toWei("100"),
    "100",
    toWei("100"),
    "100"
  );
  let tierSystemContract = await TierSystem.deployed();
  // console.log("TierSystem address ====> " + tierSystemContract.address);

  await deployer.deploy(IDOMaster, feeToken, feeWallet, feeAmount, burnPercent);
  let idoMasterContract = await IDOMaster.deployed();
  // console.log("IDO master address ====> " + idoMasterContract.address);

  await deployer.deploy(FeeProcessor, idoMasterContract.address);
  const feeProcessor = await FeeProcessor.deployed();

  await deployer.deploy(IDOProcessor, idoCreatorContract.address);
  const idoProcessor = await IDOProcessor.deployed();

  // IDOPoolFactory sözleşmesini dağıt
  await deployer.deploy(
    IDOPoolFactory,
    idoMasterContract.address,
    tierSystemContract.address
  );
  let idoPoolFactory = await IDOPoolFactory.deployed();

  // IDOCreator sözleşmesini dağıt ve IDOPoolFactory adresini ver
  await deployer.deploy(
    IDOCreator,
    idoMasterContract.address,
    tierSystemContract.address,
    feeProcessor.address,
    idoPoolFactory.address
  );
  let idoCreatorContract = await IDOCreator.deployed();

  await idoMasterContract.setCreatorProxy(idoCreatorContract.address);
  console.log("set setCreatorProxy ====> " + idoCreatorContract.address);

  console.log("TierSystem address ====> " + tierSystemContract.address);
  console.log("IDO master address ====> " + idoMasterContract.address);
  console.log("FeeProcessor address ====> " + feeProcessor.address);
  console.log("IDOPoolFactory address ====> " + idoPoolFactory.address);
  console.log("IDO creator address ====> " + idoCreatorContract.address);
  console.log("IDOProcessor address ====> " + idoProcessor.address);
  console.log("set setCreatorProxy ====> " + idoCreatorContract.address);
};
