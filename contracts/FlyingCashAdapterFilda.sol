// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCashAdapter.sol";
import "./compound/CErc20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlyingCashAdapterFilda is IFlyingCashAdapter, FlyingCashAdapterStorage, Ownable {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    address public ftoken;
    address private token;

    constructor(address _ftoken) public {
        require(_ftoken != address(0), "FlyingCashAdapterFilda: ftoken is zero address");
        ftoken = _ftoken;
        token = CErc20(ftoken).underlying();
    }

    function setWhitelist(address _account, bool _enable) external override {
        require(_account != address(0), "FlyingCashAdapterFilda: account is zero address");
        whitelist[_account] = _enable;
        emit WhitelistChanged(_account, _enable);
    }

    function deposit(uint _amount) external override {
        // save to filda
        ERC20(token).approve(ftoken, _amount);

        uint borrowAmount = getBorrowBalance();
        uint err;
        if (borrowAmount > 0) {
            if (_amount <= borrowAmount) {
                CErc20(ftoken).repayBorrow(_amount);
                return;
            }

            err = CErc20(ftoken).repayBorrow(borrowAmount);
            require(err == 0, "FlyingCashAdapterFilda: repayBorrow failed");
        }

        err = CErc20(ftoken).mint(_amount.sub(borrowAmount));
        require(err == 0, "FlyingCashAdapterFilda: mint failed");
    }

    function withdraw(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterFilda: sender is not in whitelist");

        uint savingAmount = getSavingBalance();
        uint err;
        if (savingAmount >= _amount) {
            err = CErc20(ftoken).redeemUnderlying(_amount);
            require(err == 0, "FlyingCashAdapterFilda: redeem failed");
            ERC20(token).safeTransfer(msg.sender, _amount);
            return;
        }

        if (savingAmount > 0) {
            err = CErc20(ftoken).redeemUnderlying(savingAmount);
            require(err == 0, "FlyingCashAdapterFilda: redeem failed");
        }

        err = CErc20(ftoken).borrow(_amount.sub(savingAmount));
        require(err == 0, "FlyingCashAdapterFilda: borrow failed");
        ERC20(token).safeTransfer(msg.sender, _amount);
    }

    function getSavingBalance() public view override returns (uint) {
        return CErc20(ftoken).balanceOfUnderlying(address(this));
    }

    function getBorrowBalance() public override returns (uint) {
        return CErc20(ftoken).borrowBalanceCurrent(address(this));
    }

    function claimComp() external onlyOwner {
        ComptrollerInterface comptroller = CErc20(ftoken).comptroller();
        comptroller.claimComp(address(this));

        ERC20 comp = ERC20(comptroller.getCompAddress());
        comp.safeTransfer(owner(), comp.balanceOf(address(this)));
    }
}
