// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./GovernableInitiable.sol";
import "./interface/IFlyingCash.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

// the FlyingCash implement for filda
abstract contract BaseFlyingCash is IFlyingCash, FlyingCashStorage, GovernableInitiable, PausableUpgradeable {
    using Address for address;
    using SafeERC20 for ERC20;
    using SafeERC20 for Voucher;
    using EnumerableSet for EnumerableSet.AddressSet;

    function init(address _governance, address _adapter, address _lockToken, address _voucher, address _feeManager) public virtual initializer {
        GovernableInitiable.initialize(_governance);
        PausableUpgradeable.__Pausable_init();

        require(_lockToken != address(0) && _voucher != address(0), "FlyingCash: invalid param");

        adapter = _adapter;
        lockToken = ERC20(_lockToken);
        voucher = Voucher(_voucher);
        feeManager = _feeManager;

        voucherSet.add(_voucher);
        voucherNetwork[_voucher] = 'default';

    }

    function setLockToken(address _lockToken) external override onlyGovernance {
        require(_lockToken.isContract(), "FlyingCash: lock token is not contract");

        lockToken = ERC20(_lockToken);
        if (feeManager != address(0)) {
            lockToken.safeApprove(feeManager, uint(-1));
        }
        lockToken.safeApprove(adapter, uint(-1));

        emit LockTokenChanged(_lockToken);
    }

    function setVoucher(address _voucher) external override onlyGovernance {
        require(_voucher.isContract(), "FlyingCash: voucher is not contract");

        if (voucherSet.contains(address(voucher))) {
            voucherSet.remove(address(voucher));
            voucherNetwork[address(voucher)] = '';
        }
        voucherSet.add(_voucher);
        voucherNetwork[_voucher] = 'default';
        voucher = Voucher(_voucher);
        emit VoucherChanged(_voucher);
    }

    function setFeeManager(address _feeManager) external override onlyGovernance {
        require(_feeManager.isContract(), "FlyingCash: feeManager is not contract");

        if (feeManager != address(0)) {
            lockToken.safeApprove(feeManager, 0);
        }

        feeManager = _feeManager;
        lockToken.safeApprove(feeManager, uint(-1));
        emit FeeManagerChanged(_feeManager);
    }


    function setAdapter(address _adapter) external override onlyGovernance {
        require(_adapter != address(0), "FlyingCash: adapter is zero address");
        lockToken.safeApprove(adapter, 0);
        adapter = _adapter;
        lockToken.safeApprove(adapter, uint(-1));
    }

    function setNetworkBridge(string calldata _name, address _bridge) external override onlyGovernance {
        require(bytes(_name).length != 0, "FlyingCash: invalid param");

        if (bridges[_name] != address(0)) {
            voucher.safeApprove(bridges[_name], 0);
        }

        bridges[_name] = _bridge;
        if (_bridge != address(0)) {
            voucher.safeApprove(_bridge, uint(-1));
        }

        emit BridgeChanged(_name, _bridge);
    }

    function setAcceptVouchers(address[] calldata _vouchers, bool[] calldata _accepts, string[] calldata _networks) external override onlyGovernance {
        require(_vouchers.length == _accepts.length, "FlyingCash: invalid param");
        for (uint8 i = 0; i < _vouchers.length; i++) {
            if (_accepts[i] && !voucherSet.contains(_vouchers[i])) {
                voucherSet.add(_vouchers[i]);
                voucherNetwork[_vouchers[i]] = _networks[i];
            } else {
                voucherSet.remove(_vouchers[i]);
                voucherNetwork[_vouchers[i]] = '';
            }
        }
    }

    function isAcceptVoucher(address _token) public view override returns(bool) {
        return voucherSet.contains(_token);
    }

    function getAcceptVoucherLength() external view override returns(uint) {
        return voucherSet.length();
    }

    function getAcceptVoucher(uint8 index) external view override returns(address) {
        require(index < voucherSet.length(), "FlyingCash: index out of range");
        return voucherSet.at(index);
    }

    function pause() external override onlyGovernance {
        _pause();
    }

    function unpause() external override onlyGovernance {
        _unpause();
    }

    function applyWithdraw() external override onlyGovernance {
        applyTime = block.timestamp;
    }

}
