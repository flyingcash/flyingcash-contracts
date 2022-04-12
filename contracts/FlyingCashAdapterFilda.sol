// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCashAdapter.sol";
import "./compound/CErc20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./GovernableInitiable.sol";

contract FlyingCashAdapterFilda is IFlyingCashAdapter, FlyingCashAdapterStorage, GovernableInitiable {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    address public ftoken;
    address public token;

    bool public loanOpened;

    // liquity in adapter
    uint256 public liquity;

    event LoanOpend(bool indexed _open);
    event LiquityChanged(uint256 indexed _liquity);

    function init(address _governance, address _ftoken) public initializer {
        GovernableInitiable.initialize(_governance);

        require(_ftoken != address(0), "FlyingCashAdapterFilda: ftoken is zero address");
        ftoken = _ftoken;
        token = CErc20(ftoken).underlying();
        ERC20(token).approve(ftoken, uint(-1));
    }

    function setWhitelist(address _account, bool _enable) external override onlyGovernance {
        require(_account != address(0), "FlyingCashAdapterFilda: account is zero address");
        whitelist[_account] = _enable;
        emit WhitelistChanged(_account, _enable);
    }

    function openLoan(bool _open) external onlyGovernance {
        loanOpened = _open;
        emit LoanOpend(_open);
    }

    function setLiquity(uint256 _liquity) external onlyGovernance {
        liquity = _liquity;

        uint256 balance = ERC20(token).balanceOf(address(this));
        uint256 saved = CErc20(ftoken).balanceOfUnderlying(address(this));

        uint err;
        if (balance > liquity) {
            uint borrowAmount = getBorrowBalance();
            uint amount = balance.sub(liquity);
            if (borrowAmount > 0) {
                err = CErc20(ftoken).repayBorrow(amount > borrowAmount ? borrowAmount : amount);
                require(err == 0, "FlyingCashAdapterFilda: repayBorrow failed");
                if (amount > borrowAmount) {
                    err = CErc20(ftoken).mint(amount.sub(borrowAmount));
                    require(err == 0, "FlyingCashAdapterFilda: mint failed");
                }
            } else {
                err = CErc20(ftoken).mint(amount);
                require(err == 0, "FlyingCashAdapterFilda: mint failed");
            }

        } else if (balance < liquity && saved > 0) {
            err = CErc20(ftoken).redeemUnderlying(saved > liquity.sub(balance) ? liquity.sub(balance) : saved);
            require(err == 0, "FlyingCashAdapterFilda: redeemUnderlying failed");
        }

        emit LiquityChanged(_liquity);
    }

    function deposit(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterFilda: sender is not in whitelist");

        ERC20(token).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 balance = ERC20(token).balanceOf(address(this));
        if (balance <= liquity) return;

        uint amount = balance.sub(liquity);

        // repay borrow or save to filda
        uint borrowAmount = getBorrowBalance();
        uint err;
        if (borrowAmount > 0) {
            if (amount <= borrowAmount) {
                err = CErc20(ftoken).repayBorrow(amount);
                require(err == 0, "FlyingCashAdapterFilda: repayBorrow failed");
                return;
            }

            err = CErc20(ftoken).repayBorrow(borrowAmount);
            require(err == 0, "FlyingCashAdapterFilda: repayBorrow failed");
        }

        err = CErc20(ftoken).mint(amount.sub(borrowAmount));
        require(err == 0, "FlyingCashAdapterFilda: mint failed");
    }

    function withdraw(uint _amount) external override {
        require(whitelist[msg.sender], "FlyingCashAdapterFilda: sender is not in whitelist");

        uint err;
        bool redeemFail = false;
        uint savingAmount = CErc20(ftoken).balanceOfUnderlying(address(this));
        if (savingAmount > 0) {
            err = CErc20(ftoken).redeemUnderlying(savingAmount > _amount ? _amount : savingAmount);
            if (err != 0) {
                redeemFail = true;
            }
        }
        uint256 balance = ERC20(token).balanceOf(address(this));

        if (!loanOpened || redeemFail) {
            require(balance >= _amount, "FlyingCashAdapterFilda: not enough token");
        } else if (balance < _amount) {
            err = CErc20(ftoken).borrow(_amount.sub(balance));
            require(err == 0, "FlyingCashAdapterFilda: borrow failed");
        }

        ERC20(token).safeTransfer(msg.sender, _amount);
    }

    function getSavingBalance() public override returns (uint) {
        return CErc20(ftoken).balanceOfUnderlying(address(this)).add(ERC20(token).balanceOf(address(this)));
    }

    function getBorrowBalance() public override returns (uint) {
        return CErc20(ftoken).borrowBalanceCurrent(address(this));
    }

    function claimComp() external onlyGovernance {
        ComptrollerInterface comptroller = CErc20(ftoken).comptroller();
        comptroller.claimComp(address(this));

        ERC20 comp = ERC20(comptroller.getCompAddress());
        comp.safeTransfer(governance(), comp.balanceOf(address(this)));
    }
}
