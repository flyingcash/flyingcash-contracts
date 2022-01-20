// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFeeManager.sol";
import "./BoringOwnable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract FeeManager is IFeeManager, BoringOwnable {
    using SafeMath for uint256;

    uint public basicFee = 30;
    uint private constant FEE_DENOMINATOR = 10000;

    uint public feeUpperLimit;
    uint public feeLowerLimit;

    constructor(uint lowerLimit, uint upperLimit) public {
        feeLowerLimit = lowerLimit;
        feeUpperLimit = upperLimit;
    }

    function setFee(uint fee) external onlyOwner {
        basicFee = fee;
    }

    function setLimit(uint lowerLimit, uint upperLimit) external onlyOwner {
        feeLowerLimit = lowerLimit;
        feeUpperLimit = upperLimit;
    }

    function getDepositeFee(address account, string memory network, uint amount) external override returns (uint, bool) {
        account;network;amount;
        return (0, false);
    }

    function getWithdrawFee(address account, string memory network, uint amount) external override returns (uint, bool) {
        account;network;

        uint fee = amount.mul(basicFee).div(FEE_DENOMINATOR);
        if (fee < feeLowerLimit) {
            fee = feeLowerLimit;
        } else if (fee > feeUpperLimit) {
            fee = feeUpperLimit;
        }

        return (fee, false);
    }
}
