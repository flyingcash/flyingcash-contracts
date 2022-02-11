// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "./BoringOwnable.sol";

contract FlyingCashToken is ERC20Burnable, BoringOwnable {

    address public minter;

    event MinterChanged(address _minter);

    modifier onlyMinter {
        require(msg.sender == minter, "FlyingCashToken: onlyMinter");
        _;
    }

    constructor (string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
    }

    function setMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "FlyingCashToken: minter address is zero");
        minter = _minter;
        emit MinterChanged(_minter);
    }
    
    /**
     * @dev  `amount` tokens mint to the account.
     *
     * See {ERC20-_mint}.
     */
    function mint(address _account, uint256 amount) public virtual onlyMinter {
        _mint(_account, amount);
    }
}
