// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFeeManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeManager is IFeeManager, Ownable {

    function getDepositeFee(address account, uint amount) external view override returns (uint) {
        account;amount;
        return 0;
    }

    function getWithdrawFee(address account, uint amount) external view override returns (uint) {
        account;amount;
        return 0;
    }
}
