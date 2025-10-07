// SPDX-License-Identifier: MIT
// Test version without Conflux-specific features
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract StandardERC20 is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    uint256 public constant MAX_SUPPLY = 10000000 * 10 ** 18; // 最大供应量1000万代币

    /**
     * @dev 构造函数
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _initialSupply 初始供应量
     * @param _owner 初始拥有者地址
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) ERC20(_name, _symbol) Ownable(_owner) ERC20Permit(_name) {
        // _mint(_owner, _initialSupply);
    }

    /**
     * @dev 铸造新代币（仅拥有者）
     * @param to 接收地址
     * @param amount 铸造数量
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "MyToken: Exceeds max supply"
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
            "MyToken: Array length mismatch"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(owner(), recipients[i], amounts[i]);
        }
    }

    /**
     * @dev 获取代币信息
     * @return name 代币名称
     * @return symbol 代币符号
     * @return decimals 小数位数
     * @return totalSupply 总供应量
     * @return maxSupply 最大供应量
     */
    function getTokenInfo()
        external
        view
        returns (
            string memory name,
            string memory symbol,
            uint8 decimals,
            uint256 totalSupply,
            uint256 maxSupply
        )
    {
        return (
            this.name(),
            this.symbol(),
            this.decimals(),
            this.totalSupply(),
            MAX_SUPPLY
        );
    }
}
