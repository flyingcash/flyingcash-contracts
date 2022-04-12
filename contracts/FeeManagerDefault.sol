// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFeeManager.sol";

contract FeeManagerDefault is IFeeManager {

    function getDepositeFee(address account, string memory network, uint amount) external override returns (uint, bool) {
        account;network;amount;
        return (0, false);
    }

    function getWithdrawFee(address account, string memory network, uint amount) external override returns (uint, bool) {
        account;network;amount;
        return (0, false);
    }
}
