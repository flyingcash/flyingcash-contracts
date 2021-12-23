// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./BaseFlyingCash.sol";
import "./compound/CErc20.sol";
import "./interface/IFeeManager.sol";
import "./interface/IFlyingCashAdapter.sol";
import "./interface/ITokenBridge.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// the FlyingCash implement for filda
contract FlyingCash is BaseFlyingCash {
    using Address for address;
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using SafeERC20 for Voucher;

    /* @dev relay lockToken, mint voucher and bridge voucher to another chain.
    * @param _amount the amount of lockToken
    * @param _network network name stored in bridges
    * @param _account recipient address
    */
    function deposit(uint256 _amount, string calldata _network, address _account) external override returns (uint) {
        require(_amount != 0 && bytes(_network).length > 0 && _account != address(0), "FlyingCash: invalid param");

        address bridge = bridges[_network];
        require(bridge != address(0), "FlyingCash:  network not exist");

        lockToken.safeTransferFrom(msg.sender, address(this), _amount);

        uint amount = _amount;
        if (feeManager != address(0)) {
            uint fee = IFeeManager(feeManager).getDepositeFee(msg.sender, _amount);
            amount = amount.sub(fee);
        }

        // save to adapter
        lockToken.approve(adapter, _amount);
        IFlyingCashAdapter(adapter).deposit(_amount);

        // mint token
        voucher.mint(address(this), amount);
        voucher.approve(bridge, amount);

        ITokenBridge(bridge).relayTokens(voucher, _account, amount);
    }

    /* @dev exchange voucher for token.
    * @dev unlock token on heco, mint token on other chain.
    * @param _voucher the voucher address
    * @param _amount amount of voucher
    */
    function withdraw(address _voucher, uint256 _amount) external override returns (uint) {
        require(_amount != 0, "FlyingCash: amount must greater than 0");
        require(isAcceptVoucher(_voucher), "FlyingCash:  the voucher is not accepted");

        ERC20(_voucher).safeTransferFrom(msg.sender, address(this), _amount);

        uint amount = _amount;
        if (feeManager != address(0)) {
            uint fee = IFeeManager(feeManager).getWithdrawFee(msg.sender, _amount);
            amount = amount.sub(fee);
        }

        if (_voucher == address(voucher)) {
            Voucher(_voucher).burn(_amount);
        }

        // redeem from adapter
        IFlyingCashAdapter(adapter).withdraw(amount);

        lockToken.safeTransfer(msg.sender, amount);
    }

    function getReserve() public override returns (uint) {
        uint savingBalance = IFlyingCashAdapter(adapter).getSavingBalance();
        uint borrowBalance = IFlyingCashAdapter(adapter).getBorrowBalance();

        uint vocherSupply = voucher.totalSupply();
        uint voucherBalance;
        for (uint8 i = 0; i < voucherSet.length(); i++) {
            address token = voucherSet.at(i);
            if (token == address(voucher)) continue;
            voucherBalance = voucherBalance.add(ERC20(token).balanceOf(address(this)));
        }

        return savingBalance.add(voucherBalance).sub(vocherSupply).sub(borrowBalance);
    }

    /* @dev withdraw reserve, send to governance.
    */
    function withdrawReserve() external override returns (uint) {
        uint reserve = getReserve();
        if (reserve > 0) {
            IFlyingCashAdapter(adapter).withdraw(reserve);
            lockToken.safeTransfer(governance(), reserve);
        }
        return reserve;
    }
}
