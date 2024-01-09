// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IidoMaster.sol";

contract FeeProcessor is Ownable {
    using SafeERC20 for ERC20Burnable;
    using SafeMath for uint256;

    IidoMaster public idoMaster;

    constructor(IidoMaster _idoMaster) public {
        idoMaster = _idoMaster;
    }

    function processFee() public {
        if (idoMaster.feeAmount() > 0) {
            uint256 burnAmount = idoMaster
                .feeAmount()
                .mul(idoMaster.burnPercent())
                .div(idoMaster.divider());
            idoMaster.feeToken().safeTransferFrom(
                msg.sender,
                idoMaster.feeWallet(),
                idoMaster.feeAmount().sub(burnAmount)
            );

            if (burnAmount > 0) {
                idoMaster.feeToken().safeTransferFrom(
                    msg.sender,
                    address(this),
                    burnAmount
                );
                idoMaster.feeToken().burn(burnAmount);
            }
        }
    }
}
