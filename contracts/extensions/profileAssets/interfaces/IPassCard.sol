// SPDx-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

/**
 * @dev s11e-protocol assets: PassCard asset
 */
interface IPassCard {
    function mint(address _to, string memory _tokenURI) external payable;

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);
}
