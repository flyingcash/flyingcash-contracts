// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/ITokenBridge.sol";
import "./interface/IMultiAMBErc20ToErc677.sol";

contract TokenBridge is ITokenBridge {
    IMultiAMBErc20ToErc677 public bridge;

    constructor(address _bridge) public {
        require(_bridge != address(0), "TokenBridge: _bridge is zero address");
        bridge = IMultiAMBErc20ToErc677(_bridge);
    }

    function relayTokens(ERC20 _token, address _receiver, uint256 _value) external override {
        bridge.relayTokens(ERC677(address(_token)), _receiver, _value);
    }
}
