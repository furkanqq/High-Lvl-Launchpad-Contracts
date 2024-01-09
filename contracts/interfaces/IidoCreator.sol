// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface IidoCreator {
    function createIDO(
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minStablePayment,
        uint256 _maxStablePayment,
        uint256 _maxDistributedTokenAmount,
        bool _hasWhitelisting,
        bool _enableTierSystem
    ) external;
}