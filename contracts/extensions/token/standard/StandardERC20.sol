// SPDX-License-Identifier: MIT
// Test version without Conflux-specific features,ETH version
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract StandardERC20 is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    uint256 public constant MAX_SUPPLY = 10000000 * 10 ** 18; // max supply 10000000

    /**
     * @dev constructor
     * @param _name token name
     * @param _symbol token symbol
     * @param _initialSupply initial supply（current version not used）
     * @param _owner initial owner address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) ERC20(_name, _symbol) Ownable(_owner) ERC20Permit(_name) {
        _mint(_owner, _initialSupply);
    }

    /**
     * @dev mint new tokens（only owner）
     * @param to receive address
     * @param amount mint amount
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "MyToken: Exceeds max supply");
        _mint(to, amount);
    }

    /**
     * @dev batch transfer（only owner）
     * @param recipients receive address array
     * @param amounts transfer amount array
     */
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "MyToken: Array length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(owner(), recipients[i], amounts[i]);
        }
    }

    /**
     * @dev get token info
     * @return name token name
     * @return symbol token symbol
     * @return decimals token decimals
     * @return totalSupply total supply
     * @return maxSupply max supply
     */
    function getTokenInfo()
        external
        view
        returns (string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, uint256 maxSupply)
    {
        return (this.name(), this.symbol(), this.decimals(), this.totalSupply(), MAX_SUPPLY);
    }
}
