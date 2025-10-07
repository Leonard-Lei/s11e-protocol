// //SPDX-License-Identifier: Apache-2.0
// pragma solidity >=0.8.20;

// import "./ContinuousToken.sol";
// import "hardhat/console.sol";

// contract ETHContinuousToken is ContinuousToken {
//     using Math for uint;
//     uint256 internal reserve;

//     constructor(
//         string memory _name,
//         string memory _symbol,
//         uint8 _decimals,
//         uint256 _cap,
//         uint256 _initialSupply,
//         uint32 _reserveRatio
//     ) payable {
//         reserveRatio = _reserveRatio;
//         initializeContinuousToken(_name, _symbol, _decimals, _cap);
//         _mint(_msgSender(), _initialSupply);
//         reserve = msg.value;
//         console.log("constructor reserve:", uint256(msg.value));
//         console.log("constructor _reserveRatio:", uint256(_reserveRatio));
//     }

//     // function () public payable { mint(); }
//     // receive () external payable {
//     //     mint();
//     // }

//     //! Fallback函数与Receive函数的区别是：Receive函数只在合约转账时调用，而Fallback函数除了可以在合约转账时调用外，在合约没有函数匹配或需要向合约发送附加数据时，也调用Fallback函数。
//     // fallback () external payable {
//     //     mint();
//     // }

//     // Function to deposit Ether into this contract.
//     // Call this function along with some Ether.
//     // The balance of this contract will be automatically updated.
//     function deposit() public payable {}

//     function balance() public view returns (uint) {
//         return address(this).balance;
//     }

//     // Function to withdraw all Ether from this contract.
//     function withdraw() public {
//         require(
//             hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
//             "must have admin role to withdraw"
//         );
//         // get the amount of Ether stored in this contract
//         uint amount = address(this).balance;
//         // send all Ether to owner
//         // Owner can receive Ether since the address of owner is payable
//         (bool success, ) = msg.sender.call{value: amount}("");
//         require(success, "Failed to send Ether");
//     }

//     function mint() public payable {
//         uint purchaseAmount = msg.value;
//         console.log("mint value:", uint256(purchaseAmount));
//         _continuousMint(msg.sender, purchaseAmount);
//         reserve = reserve.add(purchaseAmount);
//     }

//     function burn(uint _amount) public {
//         uint refundAmount = _continuousBurn(msg.sender, _amount);
//         reserve = reserve.sub(refundAmount);
//         address payable payableAddr = payable(msg.sender);
//         payableAddr.transfer(refundAmount);
//     }

//     function reserveBalance() public view override returns (uint) {
//         return reserve;
//     }
// }
