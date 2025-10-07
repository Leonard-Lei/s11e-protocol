// SPDX-License-Identifier: MIT
// Simplified version for better compatibility with Ganache
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleStandardERC20
 * @dev 简化版的 StandardERC20，移除了 ERC20Permit 以提高兼容性
 */
contract SimpleStandardERC20 is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 10000000 * 10 ** 18; // 最大供应量1000万代币

    /**
     * @dev 构造函数
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _initialSupply 初始供应量（已包含 decimals）
     * @param _owner 初始拥有者地址
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) ERC20(_name, _symbol) Ownable(_owner) {
        require(_initialSupply <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(_owner, _initialSupply);
    }

    /**
     * @dev 铸造新代币（仅拥有者）
     * @param to 接收地址
     * @param amount 铸造数量
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Exceeds max supply"
        );
        _mint(to, amount);
    }

    /**
     * @dev 批量转账（仅拥有者）
     * @param recipients 接收地址数组
     * @param amounts 转账数量数组
     */
    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(
            recipients.length == amounts.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(owner(), recipients[i], amounts[i]);
        }
    }

    /**
     * @dev 获取代币信息
     * @return name_ 代币名称
     * @return symbol_ 代币符号
     * @return decimals_ 小数位数
     * @return totalSupply_ 总供应量
     * @return maxSupply_ 最大供应量
     */
    function getTokenInfo()
        external
        view
        returns (
            string memory name_,
            string memory symbol_,
            uint8 decimals_,
            uint256 totalSupply_,
            uint256 maxSupply_
        )
    {
        return (
            name(),
            symbol(),
            decimals(),
            totalSupply(),
            MAX_SUPPLY
        );
    }
}

