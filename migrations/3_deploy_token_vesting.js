const TokenVesting = artifacts.require("TokenVesting");


module.exports = async function(deployer, network, accounts) {
  if (network === 'mainnet' || network === 'mainnet-fork') {
    const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
  
    const START_DATE = "1596148450";
    const FOUR_MONTHS = "10512000";
    const HALF_YEAR = "15768000";
    const YEAR = "31536000";
    const DECIMAL = "000000000000000000";
    const RESERVE = {
      company: {
        vesting: {
          beneficiary: "0x58b8654A2394d82ac6Dbf79695ED151203Ed174E",
          start: START_DATE,
          interval: HALF_YEAR,
          duration: (parseInt(HALF_YEAR) * 10).toString(),
          amount: "72000000" + DECIMAL
        }
      },
      private: {
        vesting: {
          beneficiary: "0x9a83FE670d94Deccc0C1402f5139CAD1830415C6",
          start: START_DATE,
          interval: YEAR,
          duration: (parseInt(YEAR) * 4).toString(),
          amount: "28800000" + DECIMAL
        }
      },
      team: {
        vesting: {
          beneficiary: "0xC9fB42Db2d4ab8DaC663e5E2F92fD4C73FaDDa81",
          start: START_DATE,
          interval: YEAR,
          duration: (parseInt(YEAR) * 4).toString(),
          amount: "28800000" + DECIMAL
        }
      },
      treasury: {
        vesting: {
          beneficiary: "0x9a83FE670d94Deccc0C1402f5139CAD1830415C6",
          start: START_DATE,
          interval: YEAR,
          duration: (parseInt(YEAR) * 4).toString(),
          amount: "28800000" + DECIMAL
        }
      },
      advisory: {
        vesting: {
          beneficiary: "0x92b6A336E782b6CE878372926B029eca182E04b7",
          start: START_DATE,
          interval: HALF_YEAR,
          duration: (parseInt(HALF_YEAR) * 6).toString(),
          amount: "10800000" + DECIMAL
        }
      },
      community: {
        vesting: {
          beneficiary: "0x66418E0993429efDeE1C86cadf29BC728f2550B1",
          start: 0,
          interval: 0,
          duration: 0,
          amount: "24000000" + DECIMAL
        }
      },
      marketing: {
        vesting: {
          beneficiary: "0x9a83FE670d94Deccc0C1402f5139CAD1830415C6",
          start: START_DATE,
          interval: FOUR_MONTHS,
          duration: (parseInt(FOUR_MONTHS) * 6).toString(),
          amount: "37200000" + DECIMAL
        }
      },
      publicSale: {
        vesting: {
          beneficiary: "0x419E30C386282815416a57c55D9A624902505643",
          start: 0,
          interval: 0,
          duration: 0,
          amount: "19200000" + DECIMAL
        }
      }
    }
  
    const TOTAL_SUPPLY = "192000000" + DECIMAL;
  
    console.log('RESERVE', RESERVE, 'TOTAL_SUPPLY', TOTAL_SUPPLY)
  
   await deployer.deploy(BARTToken, "BarterTrade", "BART", {gas: 6000000, from: accounts[0]});
  
    await deployer.deploy(TokenVesting, bart.address, {gas: 6000000, from: accounts[0]});
  
    let vesting = await TokenVesting.deployed();
    let cumulativeGas = 0;
    let tx;
    console.log('accounts[0]', accounts[0])
    console.log('mint all needed tokens');
    tx = await bart.mint(accounts[0], TOTAL_SUPPLY, { from: accounts[0]});
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('approve all tokens for vesting');
    tx = await bart.approve(vesting.address, TOTAL_SUPPLY, { from: accounts[0]});
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('create vesting for company');
    tx = await vesting.createVesting(
      accounts[0],
      RESERVE.company.vesting.beneficiary,
      RESERVE.company.vesting.start,
      RESERVE.company.vesting.interval,
      RESERVE.company.vesting.duration,
      RESERVE.company.vesting.amount,
      { from: accounts[0]}
    )
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('create vesting for team');
    tx = await vesting.createVesting(
      accounts[0],
      RESERVE.team.vesting.beneficiary,
      RESERVE.team.vesting.start,
      RESERVE.team.vesting.interval,
      RESERVE.team.vesting.duration,
      RESERVE.team.vesting.amount,
      { from: accounts[0]}
    )
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('create vesting for advisory');
    tx = await vesting.createVesting(
      accounts[0],
      RESERVE.advisory.vesting.beneficiary,
      RESERVE.advisory.vesting.start,
      RESERVE.advisory.vesting.interval,
      RESERVE.advisory.vesting.duration,
      RESERVE.advisory.vesting.amount,
      { from: accounts[0]}
    )
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('create vesting for marketing');
    tx = await vesting.createVesting(
      accounts[0],
      RESERVE.marketing.vesting.beneficiary,
      RESERVE.marketing.vesting.start,
      RESERVE.marketing.vesting.interval,
      RESERVE.marketing.vesting.duration,
      RESERVE.marketing.vesting.amount,
      { from: accounts[0]}
    )
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('send community token');
    tx = await bart.transfer(RESERVE.community.vesting.beneficiary, RESERVE.community.vesting.amount, { from: accounts[0]});
    cumulativeGas += tx.receipt.gasUsed;
  
    console.log('send public sale token');
    tx = await bart.transfer(RESERVE.publicSale.vesting.beneficiary, RESERVE.publicSale.vesting.amount, { from: accounts[0]});
    cumulativeGas += tx.receipt.gasUsed;
  
     console.log('add new minter');
     tx = await bart.grantRole(MINTER_ROLE, "0x4E815b68ef597767456Cf2Bb6c672c1922Aa02f0", { from: accounts[0] });
     cumulativeGas += tx.receipt.gasUsed;
  
    console.log('remove myself from minting');
    tx = await bart.renounceRole(MINTER_ROLE, accounts[0], { from: accounts[0] });
    cumulativeGas += tx.receipt.gasUsed;
     console.log('remove myself from admin');
     tx = await bart.renounceRole(DEFAULT_ADMIN_ROLE, accounts[0], { from: accounts[0] });
     cumulativeGas += tx.receipt.gasUsed;
    console.log('setup gas price', cumulativeGas, cumulativeGas * 60000000000)
  }
};
