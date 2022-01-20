// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./interface/IFeeManager.sol";
import "./BoringOwnable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FeeManagerNoAsset is IFeeManager, BoringOwnable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public reserveToken;
    mapping(string => uint256) public reserves;

    uint256 depositFeeMolecular = 200;
    uint256 withdrawRewardMolecular = 200;

    uint256 constant FEE_DENOMINATOR = 10000;

    constructor(address _token) public {
        reserveToken = ERC20(_token);
    }

    function setReserveToken(address _token) external onlyOwner {
        require(_token != address(0), "FeeManagerNoAsset: reserve token address is zero");
        reserveToken = ERC20(_token);
    }

    function setFee(uint256 _depositeFee, uint256 _withdrawReward) external onlyOwner {
        depositFeeMolecular = _depositeFee;
        withdrawRewardMolecular = _withdrawReward;
    }

    function getDepositeFee(address account, string calldata network, uint amount) external override returns (uint, bool) {
        account;

        uint fee = amount.mul(depositFeeMolecular).div(FEE_DENOMINATOR);
        reserveToken.safeTransferFrom(msg.sender, address(this), fee);

        reserves[network] = reserves[network].add(fee);

        return (fee, true);
    }

    function getWithdrawFee(address account, string calldata network, uint amount) external override returns (uint, bool) {

        if (reserves[network] > 0) {
            uint256 reward = amount.mul(withdrawRewardMolecular).div(FEE_DENOMINATOR);
            if (reward > reserves[network]) {
                reward = reserves[network];
            }

            reserves[network] = reserves[network].sub(reward);
            reserveToken.safeTransfer(account, reward);
        }

        return (0, false);
    }
}
