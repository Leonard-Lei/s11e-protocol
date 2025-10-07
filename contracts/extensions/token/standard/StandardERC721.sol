// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity >=0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Votes} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
import "../../../utils/MinimalReceiver.sol";

contract StandardERC721 is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    AccessControl,
    ERC721Burnable,
    EIP712,
    ERC721Votes,
    MinimalReceiver
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public baseURI;
    uint256 public supply;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _supply,
        address _owner
    ) ERC721(_name, _symbol) EIP712(_name, "1") {
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

    function mint(address _to, uint256 _tokenId, string memory _tokenURI) external payable onlyRole(MINTER_ROLE) {
        if (supply > 0) {
            require(_tokenId < supply, "token id over supply");
        }
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }
    /*
     *conflux version
     */
    function mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI,
        bool _addPrivilege
    ) external payable onlyRole(MINTER_ROLE) {
        if (supply > 0) {
            require(_tokenId < supply, "token id over supply");
        }
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        if (_addPrivilege) {
            address[] memory a = new address[](1);
            a[0] = _to;
            addPrivilege(a);
        }
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenURI(_tokenId, _tokenURI);
    }

    function setBaseUri(string memory _baseUri) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _baseUri;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // address = ["0x0000000000000000000000000000000000000000"] 全部代付
    function addPrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.addPrivilege(_account);
    }

    function removePrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        InternalContracts.SPONSOR_CONTROL.removePrivilege(_account);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable, ERC721Votes) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable, ERC721Votes) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl, MinimalReceiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
