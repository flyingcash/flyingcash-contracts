// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IFeeManager {
    function getDepositeFee(address account, string calldata network, uint amount) external returns (uint fee, bool feeDeducted);
    function getWithdrawFee(address account, string calldata network, uint amount) external returns (uint fee, bool feeDeducted);
}
