// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "./BoringOwnable.sol";

contract Voucher is ERC20Burnable, BoringOwnable {

    address public flyingCash;

    event FlyingCashChanged(address _flyingCash);

    modifier onlyFlyingCash {
        require(msg.sender == flyingCash, "Voucher: onlyFlyingCash");
        _;
    }

    constructor (address _flyingCash, string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
        require(_flyingCash != address(0), "Voucher: flashCash address is zero");
        flyingCash = _flyingCash;
    }

    function setFlyingCash(address _flyingCash) public onlyOwner {
        require(_flyingCash != address(0), "Voucher: flashCash address is zero");
        flyingCash = _flyingCash;
        emit FlyingCashChanged(_flyingCash);
    }
    
    /**
     * @dev  `amount` tokens mint to the account.
     *
     * See {ERC20-_mint}.
     */
    function mint(address _account, uint256 amount) public virtual onlyFlyingCash {
        _mint(_account, amount);
    }
}
