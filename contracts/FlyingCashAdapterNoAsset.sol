// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCashAdapter.sol";
import "./compound/CErc20.sol";
import "./BoringOwnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract FlyingCashAdapterNoAsset is IFlyingCashAdapter, FlyingCashAdapterStorage, ERC20Burnable, BoringOwnable {

    constructor (string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
    }

    function setWhitelist(address _account, bool _enable) external override {
        require(_account != address(0), "FlyingCashAdapterNoAsset: account is zero address");
        whitelist[_account] = _enable;
        emit WhitelistChanged(_account, _enable);
    }

    function deposit(uint _amount) external override {
        _burn(msg.sender, _amount);
    }

    function withdraw(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterNoAsset: sender is not in whitelist");
        _mint(msg.sender, _amount);
    }

    function getSavingBalance() public override returns (uint) {
        return 0;
    }

    function getBorrowBalance() public override returns (uint) {
        return totalSupply();
    }
}
