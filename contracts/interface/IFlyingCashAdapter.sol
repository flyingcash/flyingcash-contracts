// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IFlyingCashAdapter {

    function deposit(uint _amount) external;

    function withdraw(uint _amount) external;

    function getSavingBalance() external returns (uint);

    function getBorrowBalance() external returns (uint);
}

contract FlyingCashAdapterStorage {
    address public flyingCash;
}
