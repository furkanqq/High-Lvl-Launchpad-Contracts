// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./IDOPool.sol";
import "./interfaces/IidoMaster.sol";

contract IDOProcessor {
    using SafeERC20 for ERC20;

    function processIDO(
        IidoMaster _idoMaster,
        uint256 _feeFundsPercent,
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        IDOPool.PoolConfig memory _config,
        ITierSystem _tierSystem,
        address _sender
    ) external returns (address) {
        IDOPool idoPool = new IDOPool(
            _idoMaster,
            _feeFundsPercent,
            _tokenPrice,
            _rewardToken,
            _config,
            _tierSystem
        );

        idoPool.transferOwnership(_sender);

        _rewardToken.safeTransferFrom(
            _sender,
            address(idoPool),
            _config.maxDistributedTokenAmount
        );

        require(
            _rewardToken.balanceOf(address(idoPool)) ==
                _config.maxDistributedTokenAmount,
            "Unsupported token"
        );

        _idoMaster.registrateIDO(
            address(idoPool),
            _tokenPrice,
            address(0),
            address(_rewardToken),
            IidoMaster.PoolConfig({
                startTimestamp: _config.startTimestamp,
                finishTimestamp: _config.finishTimestamp,
                startClaimTimestamp: _config.startClaimTimestamp,
                maxStablePayment: _config.maxStablePayment,
                minStablePayment: _config.minStablePayment,
                maxDistributedTokenAmount: _config.maxDistributedTokenAmount,
                hasWhitelisting: _config.hasWhitelisting,
                enableTierSystem: _config.enableTierSystem
            })
        );

        return address(idoPool);
    }
}
