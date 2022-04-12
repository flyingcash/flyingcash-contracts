// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

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

    uint public constant WITHDRAW_PERIOD = 3 days;

    function init(address _governance, address _adapter, address _lockToken, address _feeManager,
            string memory _voucherName, string memory _voucherSymbol) public override initializer {
        BaseFlyingCash.init(_governance, _adapter, _lockToken, _feeManager, _voucherName, _voucherSymbol);

        if (feeManager != address(0)) {
            lockToken.safeApprove(feeManager, uint(-1));
        }
        lockToken.safeApprove(adapter, uint(-1));
    }

    /* @dev relay lockToken, mint voucher and bridge voucher to another chain.
    * @param _amount the amount of lockToken
    * @param _network network name stored in bridges
    * @param _account recipient address
    */
    function deposit(uint256 _amount, string calldata _network, address _account) external override whenNotPaused returns (uint) {
        require(_amount != 0 && bytes(_network).length > 0 && _account != address(0), "FlyingCash: invalid param");

        address bridge = bridges[_network];
        require(bridge != address(0), "FlyingCash:  network not exist");

        lockToken.safeTransferFrom(msg.sender, address(this), _amount);

        uint amount = _amount;
        uint depositeAmount = _amount;
        if (feeManager != address(0)) {
            (uint fee, bool deducted) = IFeeManager(feeManager).getDepositeFee(msg.sender, _network, _amount);
            amount = amount.sub(fee);
            if (deducted) {
                depositeAmount = depositeAmount.sub(fee);
            }
        }

        // save to adapter
        IFlyingCashAdapter(adapter).deposit(depositeAmount);

        uint256 mintAmount = amount.mul(10 ** uint(voucher.decimals())).div(10 ** uint(lockToken.decimals()));
        // mint token
        voucher.mint(address(this), mintAmount);

        ITokenBridge(bridge).relayTokens(voucher, _account, mintAmount);
        return amount;
    }

    /* @dev exchange voucher for token.
    * @dev unlock token on heco, mint token on other chain.
    * @param _voucher the voucher address
    * @param _amount amount of voucher
    */
    function withdraw(address _voucher, uint256 _amount) external override whenNotPaused returns (uint) {
        require(_amount != 0, "FlyingCash: amount must greater than 0");
        require(isAcceptVoucher(_voucher), "FlyingCash:  the voucher is not accepted");

        ERC20(_voucher).safeTransferFrom(msg.sender, address(this), _amount);

        uint amount = _amount.mul(10 ** uint(lockToken.decimals())).div(10 ** uint(ERC20(_voucher).decimals()));
        if (feeManager != address(0)) {
            (uint fee,) = IFeeManager(feeManager).getWithdrawFee(msg.sender, voucherNetwork[_voucher], amount);
            amount = amount.sub(fee);
        }

        if (_voucher == address(voucher)) {
            Voucher(_voucher).burn(_amount);
        }

        // redeem from adapter
        IFlyingCashAdapter(adapter).withdraw(amount);

        lockToken.safeTransfer(msg.sender, amount);
        return amount;
    }

    function getReserve() public override returns (uint) {
        uint savingBalance = IFlyingCashAdapter(adapter).getSavingBalance();
        uint borrowBalance = IFlyingCashAdapter(adapter).getBorrowBalance();

        uint multiple = 10 ** uint(lockToken.decimals());

        uint vocherSupply = voucher.totalSupply().mul(multiple).div(10 ** uint(voucher.decimals()));
        uint voucherBalance;
        for (uint8 i = 0; i < voucherSet.length(); i++) {
            address token = voucherSet.at(i);
            if (token == address(voucher)) continue;

            uint balance = ERC20(token).balanceOf(address(this)).mul(multiple).div(10 ** uint(ERC20(token).decimals()));
            voucherBalance = voucherBalance.add(balance);
        }

        return savingBalance.add(voucherBalance).sub(vocherSupply).sub(borrowBalance);
    }

    /* @dev withdraw reserve, send to governance.
    */
    function withdrawReserve(uint256 _amount) external override onlyGovernance {
        uint reserve = getReserve();
        if (reserve > 0) {
            uint amount = reserve > _amount ? _amount : reserve;
            IFlyingCashAdapter(adapter).withdraw(amount);
            lockToken.safeTransfer(governance(), amount);
            emit ReserveAdded(governance(), amount);
        }
    }

    function addReserve(uint _amount) external override onlyGovernance {
        require(_amount > 0, "FlyingCash: amount is 0");
        lockToken.safeTransferFrom(msg.sender, address(this), _amount);
        IFlyingCashAdapter(adapter).deposit(_amount);

        emit ReserveAdded(msg.sender, _amount);
    }
}
