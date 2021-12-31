// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/proxy/Initializable.sol";

contract GovernableInitiable is Initializable {

    bytes32 internal constant _GAVERNANCE_SLOT = bytes32(uint256(keccak256("filda.Governance.slot")) - 1);
    bytes32 internal constant _PENDING_GAVERNANCE_SLOT = bytes32(uint256(keccak256("filda.pendingGovernance.slot")) - 1);

    event GovernanceTransferred(address _old, address _new);

    function initialize(address _governance) public initializer {
        _setGovernance(_governance);
    }

    modifier onlyGovernance() {
        require(isGovernance(msg.sender), "Not governance");
        _;
    }

    function setGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "new governance shouldn't be empty");
        _setPendingGovernance(_governance);
    }

    function claimGovernance() external {
        address _pendingGovernance = pendingGovernance();

        // Checks
        require(msg.sender == _pendingGovernance, "Governable: caller != pending governance");

        emit GovernanceTransferred(governance(), _pendingGovernance);
        _setGovernance(_pendingGovernance);
        _setPendingGovernance(address(0));
    }

    function _setGovernance(address _governance) private {
        setAddress(_GAVERNANCE_SLOT, _governance);
    }

    function _setPendingGovernance(address _pendingGovernance) private {
        setAddress(_PENDING_GAVERNANCE_SLOT, _pendingGovernance);
    }

    function pendingGovernance() public view returns(address) {
        return getAddress(_PENDING_GAVERNANCE_SLOT);
    }

    function governance() public view returns (address) {
        return getAddress(_GAVERNANCE_SLOT);
    }

    function isGovernance(address account) public view returns (bool) {
        return account == governance();
    }

    function getAddress(bytes32 slot) private view returns(address addr) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            addr := sload(slot)
        }
    }

    function setAddress(bytes32 slot, address addr) private {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, addr)
        }
    }
}
