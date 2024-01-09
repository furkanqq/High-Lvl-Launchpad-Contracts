// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

interface IidoMaster {
    struct PoolConfig {
        uint256 startTimestamp;
        uint256 finishTimestamp;
        uint256 startClaimTimestamp;
        uint256 maxStablePayment;
        uint256 minStablePayment;
        uint256 maxDistributedTokenAmount;
        bool hasWhitelisting;
        bool enableTierSystem;
    }

    function feeToken() external pure returns (ERC20Burnable);

    function feeWallet() external pure returns (address payable);

    function feeAmount() external pure returns (uint256);

    function burnPercent() external pure returns (uint256);

    function divider() external pure returns (uint256);

    function feeFundsPercent() external pure returns (uint256);

    function registrateIDO(
        address _poolAddress,
        uint256 _tokenPrice,
        address _payableToken,
        address _rewardToken,
        PoolConfig memory _config
    ) external;
}
