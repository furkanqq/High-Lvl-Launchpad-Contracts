// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/ITierSystem.sol";


contract TierSystem is ITierSystem, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public usersBalance;

    event SetUserBalance(address account , uint256 balance);

    TierInfo public bronzeTier;
    TierInfo public silverTier;
    TierInfo public goldTier;
    TierInfo public platinumTier;
    TierInfo public diamondTier;

    struct TierInfo {
        uint256 blnAmount;
        uint256 discount;

    }
    constructor(
        uint256 _BronzeBlnAmount,
        uint256 _BronzePercent,
        uint256 _SilverBlnAmount,
        uint256 _SilverPercent,
        uint256 _GoldBlnAmount,
        uint256 _GoldPercent,
        uint256 _PlatinumBlnAmount,
        uint256 _PlatinumPercent,
        uint256 _DiamondBlnAmount,
        uint256 _DiamondPercent
    ) public { 
        setTier(_BronzeBlnAmount, _BronzePercent , _SilverBlnAmount, _SilverPercent, _GoldBlnAmount, _GoldPercent, _PlatinumBlnAmount, _PlatinumPercent, _DiamondBlnAmount, _DiamondPercent);
    }

    function setTier(
        uint256 _BronzeBlnAmount,
        uint256 _BronzePercent,
        uint256 _SilverBlnAmount,
        uint256 _SilverPercent,
        uint256 _GoldBlnAmount,
        uint256 _GoldPercent,
        uint256 _PlatinumBlnAmount,
        uint256 _PlatinumPercent,
        uint256 _DiamondBlnAmount,
        uint256 _DiamondPercent
    ) public onlyOwner {
        bronzeTier.blnAmount = _BronzeBlnAmount;
        bronzeTier.discount = _BronzePercent;
        silverTier.blnAmount = _SilverBlnAmount;
        silverTier.discount = _SilverPercent;
        goldTier.blnAmount = _GoldBlnAmount;
        goldTier.discount = _GoldPercent;
        platinumTier.blnAmount = _PlatinumBlnAmount;
        platinumTier.discount = _PlatinumPercent;
        diamondTier.blnAmount = _DiamondBlnAmount;
        diamondTier.discount = _DiamondPercent;
    }
    function addBalances(address[] memory addresses,uint256[] memory _balances) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            usersBalance[addresses[i]] = _balances[i];
            emit SetUserBalance(addresses[i], _balances[i]);
        }
    }
    function getMaxEthPayment(address user , uint256 maxEthPayment) public view override returns(uint256) {
        uint256 _blnBalance = usersBalance[user];
        if(_blnBalance  >= diamondTier.blnAmount) {
            return maxEthPayment.mul(100 - diamondTier.discount).div(100);
        } else if(_blnBalance >= platinumTier.blnAmount) {
            return maxEthPayment.mul(100 - platinumTier.discount).div(100);
        } else if(_blnBalance >= goldTier.blnAmount) {
            return maxEthPayment.mul(100 - goldTier.discount).div(100);
        } else if(_blnBalance >= silverTier.blnAmount) {
            return maxEthPayment.mul(100 - silverTier.discount).div(100);
        } else if(_blnBalance >= bronzeTier.blnAmount) {
            return maxEthPayment.mul(100 - bronzeTier.discount).div(100);
        } else {
            return maxEthPayment;
        }
    }
}