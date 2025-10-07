// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity >=0.8.20;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {
    ERC20BurnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {
    ERC20FlashMintUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20FlashMintUpgradeable.sol";
import {
    ERC20PausableUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";

contract UpgradeableERC20V2 is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    ERC1363Upgradeable,
    ERC20PermitUpgradeable,
    ERC20FlashMintUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // V2 新增：最大供应量限制
    uint256 public maxSupply;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC1363_init();
        __ERC20Permit_init(_name);
        __ERC20FlashMint_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _owner);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, _owner);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _mint(_owner, _initialSupply * 10 ** decimals());
    }

    /**
     * @dev V2 新增：初始化最大供应量
     * @param _maxSupply 最大供应量
     */
    function initializeV2(uint256 _maxSupply) public reinitializer(2) {
        maxSupply = _maxSupply;
    }

    /**
     * @dev Transfer tokens with privilege
     * @param _recipient The address of the recipient
     * @param _amount The amount of tokens to transfer
     * @param _addPrivilege Whether to add privilege, if true, the recipient will be added to the privilege list
     * @return bool success
     */
    function transfer(address _recipient, uint256 _amount, bool _addPrivilege) public returns (bool) {
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

    /**
     * @dev V2 增强：铸造时检查最大供应量
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        if (maxSupply > 0) {
            require(totalSupply() + amount <= maxSupply, "UpgradeableERC20V2: Exceeds max supply");
        }
        _mint(to, amount);
    }

    /**
     * @dev V2 新增：批量转账功能
     * @param recipients 接收地址数组
     * @param amounts 转账数量数组
     */
    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(recipients.length == amounts.length, "UpgradeableERC20V2: Array length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(_msgSender(), recipients[i], amounts[i]);
        }
    }

    /**
     * @dev V2 新增：获取代币信息
     */
    function getTokenInfo()
        external
        view
        returns (string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, uint256 maxSupply_)
    {
        return (this.name(), this.symbol(), this.decimals(), this.totalSupply(), maxSupply);
    }

    /**
     * @dev Add privilege to the address
     * @param _account The address of the account to add privilege
     * address = ["0x0000000000000000000000000000000000000000"] all pay
     */
    function addPrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.addPrivilege(_account);
    }

    function removePrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.removePrivilege(_account);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControlUpgradeable, ERC1363Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Allows all Ether transfers
     */
    receive() external payable virtual {}

    function withdraw(uint256 _amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have admin role to withdraw");
        require(_amount <= address(this).balance, "insufficient balance");
        payable(_msgSender()).transfer(_amount);
    }

    /**
     * @dev Returns the amount of TRX/BNB owned by contract.
     */
    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}
