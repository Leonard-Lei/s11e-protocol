// SPDx-License-Identifier: Apache-2.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
import "./interfaces/CRC1155Enumerable.sol";
import "./interfaces/CRC1155Metadata.sol";

contract POAP is
    ERC1155,
    AccessControl,
    ERC1155Pausable,
    ERC1155Burnable,
    CRC1155Metadata,
    CRC1155Enumerable
{
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public supply;
    string public baseURI;
    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) private tokenURIs_;

    // Mapping from owner to owned token IDs for enumeration.
    mapping(address => EnumerableSet.UintSet) private _ownedTokens;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _supply,
        address _owner
    ) ERC1155(_baseURI) CRC1155Metadata(_name, _symbol) {
        supply = _supply;
        baseURI = _baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _owner);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        if (supply > 0) {
            require(id < supply, "token id over supply");
        }
        _mint(account, id, amount, data);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        string memory _tokenURI,
        bool _addPrivilege,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        if (supply > 0) {
            require(id < supply, "token id over supply");
        }
        _mint(account, id, amount, data);
        _setURI(id, _tokenURI);
        if (_addPrivilege) {
            address[] memory a = new address[](1);
            a[0] = account;
            addPrivilege(a);
        }
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        // TODO: 校验ids.size
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the concatenation of the `_baseURI`
     * and the token-specific uri if the latter is set
     *
     * This enables the following behaviors:
     *
     * - if `tokenURIs_[tokenId]` is set, then the result is the concatenation
     *   of `_baseURI` and `tokenURIs_[tokenId]` (keep in mind that `_baseURI`
     *   is empty per default);
     *
     * - if `tokenURIs_[tokenId]` is NOT set then we fallback to `super.uri()`
     *   which in most cases will contain `ERC1155._uri`;
     *
     * - if `tokenURIs_[tokenId]` is NOT set, and if the parents do not have a
     *   uri value set, then the result is empty.
     */
    function uri(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC1155, IERC1155MetadataURI)
        returns (string memory)
    {
        string memory tokenURI = tokenURIs_[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via string.concat).
        return
            bytes(tokenURI).length > 0
                ? string.concat(baseURI, tokenURI)
                : super.uri(tokenId);
    }

    function setTokenURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) public virtual onlyRole(MINTER_ROLE) {
        _setURI(_tokenId, _tokenURI);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return uri(tokenId);
    }

    function setBaseUri(
        string memory _baseUri
    ) public virtual onlyRole(MINTER_ROLE) {
        baseURI = _baseUri;
    }

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual {
        tokenURIs_[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function _setBaseURI(string memory _baseURI) internal virtual {
        baseURI = _baseURI;
    }

    /**
     * @dev Indicates whether the specified `tokenId` exists or not.
     */
    function exists(
        uint256 tokenId
    ) public view virtual override returns (bool) {
        return _totalSupplies[tokenId] > 0;
    }

    // address = ["0x0000000000000000000000000000000000000000"] 全部代付
    function addPrivilege(
        address[] memory _account
    ) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.addPrivilege(_account);
    }

    function removePrivilege(
        address[] memory _account
    ) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.removePrivilege(_account);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable) {
        super._update(from, to, ids, values);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(IERC165, ERC1155, AccessControl, CRC1155Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
