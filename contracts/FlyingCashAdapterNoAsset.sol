// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCashAdapter.sol";
import "./FlyingCashToken.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract FlyingCashAdapterNoAsset is IFlyingCashAdapter, FlyingCashAdapterStorage, Initializable {
    using SafeERC20 for FlyingCashToken;
    using Address for address;

    FlyingCashToken public token;

    modifier onlyFlyingCash {
        require(msg.sender == flyingCash, "FlyingCashAdapterFilda: onlyFlyingCash");
        _;
    }

    function init(address _token, address _flyingCash) public initializer {
        require(_token != address(0), "FlyingCashAdapterNoAsset: token is zero address");
        require(_flyingCash.isContract(), "Voucher: flashCash address is not contract");
        flyingCash = _flyingCash;
        token = FlyingCashToken(_token);
    }

    function deposit(uint _amount) external override onlyFlyingCash {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        token.burn(_amount);
    }

    function withdraw(uint _amount) external override onlyFlyingCash {
        token.mint(msg.sender, _amount);
    }

    function getSavingBalance() public override returns (uint) {
        return 0;
    }

    function getBorrowBalance() public override returns (uint) {
        return token.totalSupply();
    }
}
