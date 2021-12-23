// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

contract FlyingCashProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address admin_, bytes memory _data) public TransparentUpgradeableProxy(_logic, admin_, _data) {
    }
}
