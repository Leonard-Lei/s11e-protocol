// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MinimalReceiver is AccessControl, ERC721Holder, ERC1155Holder {
    /**
     * @dev Allows all Ether transfers
     */
    receive() external payable virtual {}

    function withdraw(uint256 _amount) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role to withdraw"
        );
        require(_amount <= address(this).balance, "insufficient balance");
        payable(_msgSender()).transfer(_amount);
    }

    /**
     * @dev Returns the amount of TRX/BNB owned by contract.
     */
    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControl, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
