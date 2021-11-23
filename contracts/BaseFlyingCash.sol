// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFlyingCash.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// the FlyingCash implement for filda
abstract contract BaseFlyingCash is IFlyingCash, FlyingCashStorage, Initializable, Ownable {
    using Address for address;
    using SafeERC20 for ERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    function init(address _lockToken, address _voucher, address _feeManager) public initializer {
        require(_lockToken != address(0) && _voucher != address(0), "FlyingCash: invalid param");

        lockToken = ERC20(_lockToken);
        voucher = Voucher(_voucher);
        feeManager = _feeManager;

        voucherSet.add(_voucher);
    }

    function setLockToken(address _lockToken) external override onlyOwner {
        require(_lockToken.isContract(), "FlyingCash: lock token is not contract");

        lockToken = ERC20(_lockToken);
        emit LockTokenChanged(_lockToken);
    }

    function setVoucher(address _voucher) external override onlyOwner {
        require(_voucher.isContract(), "FlyingCash: voucher is not contract");

        if (voucherSet.contains(address(voucher))) {
            voucherSet.remove(address(voucher));
        }
        voucherSet.add(_voucher);
        voucher = Voucher(_voucher);
        emit VoucherChanged(_voucher);
    }

    function setFeeManager(address _feeManager) external override onlyOwner {
        require(_feeManager.isContract(), "FlyingCash: feeManager is not contract");

        feeManager = _feeManager;
        emit FeeManagerChanged(_feeManager);
    }

    function setNetworkBridge(string calldata _name, address _bridge) external override onlyOwner {
        require(bytes(_name).length != 0, "FlyingCash: invalid param");

        bridges[_name] = _bridge;
        emit BridgeChanged(_name, _bridge);
    }

    function setAcceptVouchers(address[] calldata _vouchers, bool[] calldata _accepts) external override onlyOwner {
        require(_vouchers.length == _accepts.length, "FlyingCash: invalid param");
        for (uint8 i = 0; i < _vouchers.length; i++) {
            if (_accepts[i] && !voucherSet.contains(_vouchers[i])) {
                voucherSet.add(_vouchers[i]);
            } else {
                voucherSet.remove(_vouchers[i]);
            }
        }
    }

    function isAcceptVoucher(address _token) public view override returns(bool) {
        return voucherSet.contains(_token);
    }

}
