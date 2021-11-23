// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IFeeManager {
    function getDepositeFee(address account, uint amount) external view returns (uint);
    function getWithdrawFee(address account, uint amount) external view returns (uint);
}
