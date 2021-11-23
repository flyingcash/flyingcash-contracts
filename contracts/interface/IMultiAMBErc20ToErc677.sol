// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./ERC677.sol";

interface IMultiAMBErc20ToErc677 {
    function relayTokens(ERC677 token, address _receiver, uint256 _value) external;
}
