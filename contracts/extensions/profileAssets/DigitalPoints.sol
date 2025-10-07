// SPDx-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
import "../../utils/MinimalReceiver.sol";

/**
 * @dev s11e-protocol assets: digital points asset
 */
contract DigitalPoints is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ERC20Permit,
    MinimalReceiver
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, _owner);
        _mint(_owner, _initialSupply * 10 ** decimals());
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _owner);
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        bool _addPrivilege
    ) public returns (bool) {
        _transfer(_msgSender(), _recipient, _amount);
        if (_addPrivilege) {
            address[] memory a = new address[](1);
            a[0] = _recipient;
            addPrivilege(a);
        }
        return true;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    // address = ["0x0000000000000000000000000000000000000000"] 全部代付
    function addPrivilege(
        address[] memory _account
    ) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.addPrivilege(_account);
    }

    function removePrivilege(
        address[] memory _account
    ) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.removePrivilege(_account);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(MinimalReceiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
