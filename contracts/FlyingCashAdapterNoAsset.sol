// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCashAdapter.sol";
import "./BoringOwnable.sol";
import "./FlyingCashToken.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./GovernableInitiable.sol";

contract FlyingCashAdapterNoAsset is IFlyingCashAdapter, FlyingCashAdapterStorage, GovernableInitiable {
    using SafeERC20 for FlyingCashToken;

    FlyingCashToken public token;

    function init(address _governance, address _token) public initializer {
        GovernableInitiable.initialize(_governance);

        require(_token != address(0), "FlyingCashAdapterNoAsset: token is zero address");
        token = FlyingCashToken(_token);
    }

    function setWhitelist(address _account, bool _enable) external override onlyGovernance {
        require(_account != address(0), "FlyingCashAdapterNoAsset: account is zero address");
        whitelist[_account] = _enable;
        emit WhitelistChanged(_account, _enable);
    }

    function deposit(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterNoAsset: sender is not in whitelist");
        token.safeTransferFrom(msg.sender, address(this), _amount);
        token.burn(_amount);
    }

    function withdraw(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterNoAsset: sender is not in whitelist");
        token.mint(msg.sender, _amount);
    }

    function repayBorrow(uint _amount) external override {
        _amount;
        require(false, "FlyingCashAdapterNoAsset: repayBorrow not implemented");
    }

    function getSavingBalance() public override returns (uint) {
        return 0;
    }

    function getBorrowBalance() public override returns (uint) {
        return token.totalSupply();
    }
}
