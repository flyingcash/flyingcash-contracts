// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ComptrollerInterface {
    function claimComp(address holder) external;
    function getCompAddress() external view returns (address);
}
