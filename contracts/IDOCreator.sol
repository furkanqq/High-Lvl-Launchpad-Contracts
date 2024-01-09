// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "./IDOPool.sol";
import "./interfaces/IidoMaster.sol";
import "./FeeProcessor.sol";
import "./IDOProcessor.sol"; // Yeni ekledik

contract IDOCreator is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Burnable;
    using SafeERC20 for ERC20;

    IidoMaster public idoMaster;
    ITierSystem public tierSystem;
    FeeProcessor public feeProcessor;
    IDOProcessor public idoProcessor;

    struct PoolConfig {
        uint256 startTimestamp;
        uint256 finishTimestamp;
        uint256 startClaimTimestamp;
        uint256 minStablePayment;
        uint256 maxStablePayment;
        uint256 maxDistributedTokenAmount;
        bool hasWhitelisting;
        bool enableTierSystem;
    }

    constructor(
        IidoMaster _idoMaster,
        ITierSystem _tierSystem,
        FeeProcessor _feeProcessor,
        IDOProcessor _idoProcessor
    ) public {
        idoMaster = _idoMaster;
        tierSystem = _tierSystem;
        feeProcessor = _feeProcessor;
        idoProcessor = _idoProcessor;
    }

    function createIDO(
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        PoolConfig memory _config
    ) external returns (address) {
        feeProcessor.processFee();

        return
            idoProcessor.processIDO(
                idoMaster,
                idoMaster.feeFundsPercent(),
                _tokenPrice,
                _rewardToken,
                IDOPool.PoolConfig({
                    startTimestamp: _config.startTimestamp,
                    finishTimestamp: _config.finishTimestamp,
                    startClaimTimestamp: _config.startClaimTimestamp,
                    maxStablePayment: _config.maxStablePayment,
                    minStablePayment: _config.minStablePayment,
                    maxDistributedTokenAmount: _config
                        .maxDistributedTokenAmount,
                    hasWhitelisting: _config.hasWhitelisting,
                    enableTierSystem: _config.enableTierSystem
                }),
                tierSystem,
                msg.sender
            );
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setTierSystem(ITierSystem _tierSystem) external onlyOwner {
        tierSystem = _tierSystem;
    }
}
