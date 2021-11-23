// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./ERC677.sol";

abstract contract IBurnableMintableERC677Token is ERC677 {
    function mint(address _to, uint256 _amount) public virtual returns (bool);
    function burn(uint256 _value) public virtual;
    function claimTokens(address _token, address _to) public virtual;
}
