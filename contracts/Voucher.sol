// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Voucher is ERC20Burnable {
    using Address for address;

    address public flyingCash;

    event FlyingCashChanged(address _flyingCash);

    modifier onlyFlyingCash {
        require(msg.sender == flyingCash, "Voucher: onlyFlyingCash");
        _;
    }

    constructor (address flyingcash_, string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
        require(flyingcash_.isContract(), "Voucher: flashCash address is not contract");
        flyingCash = flyingcash_;
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
