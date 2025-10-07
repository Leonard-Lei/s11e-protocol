// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

contract SimpleToken {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    
    constructor() {
        totalSupply = 1000000 * 10**18;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }
}

