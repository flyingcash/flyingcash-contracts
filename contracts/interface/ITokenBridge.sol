// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenBridge {
    function relayTokens(ERC20 _token, address _receiver, uint256 _value) external;
}
