// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./ComptrollerInterface.sol";

interface CErc20 {

    /*** User Interface ***/

    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function comptroller() external view returns (ComptrollerInterface);
    function underlying() external view returns (address);
    function balanceOfUnderlying(address account) external returns (uint);
    function balanceOf(address account) external view returns (uint);
}
