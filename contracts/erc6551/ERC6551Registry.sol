// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;
// eth EVM
// import "@openzeppelin/contracts/utils/Create2.sol";
// conflux EVM
import "@confluxfans/contracts/utils/Create2.sol";
import "./interfaces/IERC6551Registry.sol";
import "./libs/ERC6551BytecodeLib.sol";
import "./libs/MinimalProxyStore.sol";

contract ERC6551Registry is IERC6551Registry {
    error InitializationFailed();

    /**
     * @dev Address of the account implementation
     */
    // address public immutable implementation;
    address public immutable erc6551AccountImplementation;

    constructor(address _implementation) {
        erc6551AccountImplementation = _implementation;
    }

    /**
     * @dev Creates the account for an ERC721 token. Will revert if account has already been deployed
     *
     * @param _chainId the chainid of the network the ERC721 token exists on
     * @param _tokenCollection the contract address of the ERC721 token which will control the deployed account
     * @param _tokenId the token ID of the ERC721 token which will control the deployed account
     * @return The address of the deployed ccount
     */
    function createAccount(
        uint256 _chainId,
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) external returns (address) {
        return _createAccount(_chainId, _tokenCollection, _tokenId, _salt);
    }

    /**
     * @dev Deploys the account for an ERC721 token. Will revert if account has already been deployed
     *
     * @param _tokenCollection the contract address of the ERC721 token which will control the deployed account
     * @param _tokenId the token ID of the ERC721 token which will control the deployed account
     * @return The address of the deployed account
     */
    function createAccount(
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) external returns (address) {
        return _createAccount(block.chainid, _tokenCollection, _tokenId, _salt);
    }

    function createAccount(
        address _implementation,
        uint256 _chainId,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _salt,
        bytes calldata initData
    ) external returns (address) {
        bytes memory code = ERC6551BytecodeLib.getCreationCode(
            _implementation,
            _chainId,
            _tokenContract,
            _tokenId,
            _salt
        );

        address accountProxy = Create2.computeAddress(
            bytes32(_salt),
            keccak256(code)
        );

        if (accountProxy.code.length != 0) return accountProxy;

        emit AccountCreated(
            accountProxy,
            _implementation,
            _chainId,
            _tokenContract,
            _tokenId,
            _salt
        );

        accountProxy = Create2.deploy(0, bytes32(_salt), code);

        if (initData.length != 0) {
            (bool success, ) = accountProxy.call(initData);
            if (!success) revert InitializationFailed();
        }

        return accountProxy;
    }

    function getCode(
        address _implementation,
        uint256 _chainId,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _salt
    ) public pure returns (bytes memory) {
        bytes memory code = ERC6551BytecodeLib.getCreationCode(
            _implementation,
            _chainId,
            _tokenContract,
            _tokenId,
            _salt
        );
        return code;
    }

    function account(
        address _implementation,
        uint256 _chainId,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _salt
    ) external view returns (address) {
        bytes32 bytecodeHash = keccak256(
            ERC6551BytecodeLib.getCreationCode(
                _implementation,
                _chainId,
                _tokenContract,
                _tokenId,
                _salt
            )
        );

        return Create2.computeAddress(bytes32(_salt), bytecodeHash);
    }

    /**
     * @dev Gets the address of the account for an ERC721 token. If account is
     * not yet deployed, returns the address it will be deployed to
     *
     * @param _chainId the chainid of the network the ERC721 token exists on
     * @param _tokenCollection the address of the ERC721 token contract
     * @param _tokenId the _tokenId of the ERC721 token that controls the account
     * @return The account address
     */
    function account(
        uint256 _chainId,
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) external view returns (address) {
        return _account(_chainId, _tokenCollection, _tokenId, _salt);
    }

    /**
     * @dev Gets the address of the account for an ERC721 token. If account is
     * not yet deployed, returns the address it will be deployed to
     *
     * @param _tokenCollection the address of the ERC721 token contract
     * @param _tokenId the tokenId of the ERC721 token that controls the account
     * @return The account address
     */
    function account(
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) external view returns (address) {
        return _account(block.chainid, _tokenCollection, _tokenId, _salt);
    }

    function _createAccount(
        uint256 _chainId,
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) internal returns (address) {
        bytes memory encodedTokenData = abi.encode(
            _chainId,
            _tokenCollection,
            _tokenId
        );
        address accountProxy = MinimalProxyStore.cloneDeterministic(
            erc6551AccountImplementation,
            encodedTokenData,
            _salt
        );

        emit AccountCreated(
            accountProxy,
            erc6551AccountImplementation,
            _chainId,
            _tokenCollection,
            _tokenId,
            _salt
        );

        return accountProxy;
    }

    function _account(
        uint256 _chainId,
        address _tokenCollection,
        uint256 _tokenId,
        uint256 _salt
    ) internal view returns (address) {
        bytes memory encodedTokenData = abi.encode(
            _chainId,
            _tokenCollection,
            _tokenId
        );

        address accountProxy = MinimalProxyStore.predictDeterministicAddress(
            erc6551AccountImplementation,
            encodedTokenData,
            _salt
        );

        return accountProxy;
    }
}
