//SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";


contract ValidGasPrice is Context, AccessControl{
    uint256 public maxGasPrice = 1 * 10**18;

    modifier validGasPrice() {
        require(tx.gasprice <= maxGasPrice, "Gas price must be <= maximum gas price to prevent front running attacks.");
        _;
    }

    function setMaxGasPrice(uint256 newPrice) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have pauser role to pause");
        maxGasPrice = newPrice;
    }
}