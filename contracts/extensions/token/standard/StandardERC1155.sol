// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity >=0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract StandardERC1155 is ERC1155, AccessControl, ERC1155Pausable, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public maxSupply;
    string public name;
    string public symbol;
    string public baseURI;
    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) private _tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxSupply,
        address _owner
    ) ERC1155(_baseURI) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        baseURI = _baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _owner);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, _owner);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
        if (maxSupply > 0) {
            require(id < maxSupply, "StandardERC1155: token id exceeds max supply");
        }
        _mint(account, id, amount, data);
    }

    function mintWithURI(
        address account,
        uint256 id,
        uint256 amount,
        string memory tokenURI_,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        if (maxSupply > 0) {
            require(id < maxSupply, "StandardERC1155: token id exceeds max supply");
        }
        _mint(account, id, amount, data);
        _setTokenURI(id, tokenURI_);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        if (maxSupply > 0) {
            for (uint256 i = 0; i < ids.length; i++) {
                require(ids[i] < maxSupply, "StandardERC1155: token id exceeds max supply");
            }
        }
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the ERC].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI_ = _tokenURIs[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via string.concat).
        return bytes(tokenURI_).length > 0 ? string.concat(baseURI, tokenURI_) : super.uri(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI_) public virtual onlyRole(URI_SETTER_ROLE) {
        _setTokenURI(tokenId, tokenURI_);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return uri(tokenId);
    }

    function setBaseURI(string memory baseURI_) public virtual onlyRole(URI_SETTER_ROLE) {
        _setBaseURI(baseURI_);
    }

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal virtual {
        _tokenURIs[tokenId] = tokenURI_;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        baseURI = baseURI_;
    }
    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
