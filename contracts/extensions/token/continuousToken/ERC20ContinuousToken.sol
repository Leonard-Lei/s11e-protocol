// //SPDX-License-Identifier: Apache-2.0
// pragma solidity >=0.8.20;

// import "./ContinuousToken.sol";

// // https://github.com/dOrgTech/OpenRaise/tree/master

// // Need additional attributes for creator / caretaker address and fees
// // creatorAddress
// // mintCreatorFee
// // burnCreatorFee
// // caretakerAddress
// // caretakerFee
// // mintCaretakerFee
// // burnCaretakerFee
// // TODO: Define ERC20ContinuousTokenWithFees
// contract ERC20ContinuousToken is ContinuousToken {
//     ERC20 public collateralToken;

//     constructor(
//         string memory _name,
//         string memory _symbol,
//         uint8 _decimals,
//         uint256 _cap,
//         uint256 _initialSupply,
//         uint32 _reserveRatio,
//         ERC20 _collateralToken
//     ) {
//         reserveRatio = _reserveRatio;
//         initializeContinuousToken(_name, _symbol, _decimals, _cap);
//         _mint(_msgSender(), _initialSupply);

//         collateralToken = _collateralToken;
//     }

//     // function () public { revert("Cannot call fallback function."); }
//     //! Fallback函数与Receive函数的区别是：Receive函数只在合约转账时调用，而Fallback函数除了可以在合约转账时调用外，在合约没有函数匹配或需要向合约发送附加数据时，也调用Fallback函数。
//     // fallback () external payable {
//     //     mint();
//     // }
//     receive() external payable {
//         revert("Cannot call fallback function.");
//     }

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

//     function mint(uint _amount) public {
//         _continuousMint(msg.sender, _amount);
//         require(
//             collateralToken.transferFrom(msg.sender, address(this), _amount),
//             "mint() ERC20.transferFrom failed."
//         );
//     }

//     function burn(uint _amount) public {
//         uint returnAmount = _continuousBurn(msg.sender, _amount);
//         require(
//             collateralToken.transfer(msg.sender, returnAmount),
//             "burn() ERC20.transfer failed."
//         );
//     }

//     function reserveBalance() public view override returns (uint) {
//         return collateralToken.balanceOf(address(this));
//     }
// }
