// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IFlyingCashAdapter {
    event WhitelistChanged(address _account, bool _enable);

    function setWhitelist(address _account, bool _enable) external;

    function deposit(uint _amount) external;

    function withdraw(uint _amount) external;

    function getSavingBalance() external view returns (uint);

    function getBorrowBalance() external returns (uint);
}

contract FlyingCashAdapterStorage {
    mapping(address => bool) public whitelist;
}
