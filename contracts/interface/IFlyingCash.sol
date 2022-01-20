// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../Voucher.sol";

interface IFlyingCash {

    event LockTokenChanged(address indexed _lockToken);
    event VoucherChanged(address indexed _voucher);
    event FeeManagerChanged(address indexed _feeManager);
    event BridgeChanged(string _name, address _bridge);
    event ReserveAdded(address _account, uint256 indexed _amount);
    event ReserveWithdrawn(address _account, uint256 indexed _amount);

    function setLockToken(address _lockToken) external;

    function setVoucher(address _voucher) external;

    function setFeeManager(address _feeManager) external;

    function setAdapter(address _adapter) external;

    function setNetworkBridge(string calldata _name, address _bridge) external;

    function setAcceptVouchers(address[] calldata _vouchers, bool[] calldata _accepts, string[] calldata _networks) external;

    function isAcceptVoucher(address _token) external view returns(bool);

    function getAcceptVoucherLength() external view returns(uint);

    function getAcceptVoucher(uint8 index) external view returns(address);

    function pause() external;
    function unpause() external;

    /* @dev relay lockToken, mint voucher and bridge voucher to another chain.
    * @param _amount the amount of lockToken
    * @param _network network name stored in bridges
    * @param _account recipient address
    */
    function deposit(uint256 _amount, string calldata _network, address _account) external returns (uint);

    /* @dev exchange voucher for token.
    * @dev unlock token on heco, mint token on other chain.
    * @param _voucher the voucher address
    * @param _amount amount of voucher
    */
    function withdraw(address _voucher, uint256 _amount) external returns (uint);

    /* @dev get reserve amount in this contract.
    */
    function getReserve() external returns (uint);

    /* @dev withdraw reserve, only governance.
    */
    function withdrawReserve(uint256 _amount) external;

    /* @dev apply for withdraw tokens, only governance.
    */
    function applyWithdraw() external;

    /* @dev withdraw vouchers and lock token, only governance.
    */
    function withdraw() external;

    /* @dev add reserve to flyingCash, only governance.
    */
    function addReserve(uint _amount) external;

}

contract FlyingCashStorage {

    ERC20 public lockToken;
    Voucher public voucher;

    address public feeManager;
    mapping(string => address) public bridges;

    address public adapter;

    EnumerableSet.AddressSet internal voucherSet;
    mapping(address => string) public voucherNetwork;

    uint applyTime;
}
