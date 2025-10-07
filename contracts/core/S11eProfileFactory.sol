//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "../utils/CloneFactory.sol";
import "./S11eProfile.sol";

import "hardhat/console.sol";

/**
 * @dev s11e-protocol profile factory contract
 * 1.Minimal Proxy Contract mode create a new profile contract
 * 2.manange and record the new profile contract
 */
// 通过 EIP1167 创建代理合约可以节省大量创建合约的 gas 费，因为在方法调用时会用到 delegatecall，也会多少增加一点儿合约方法调用的费用。如果合约不是特别大，并且合约创建出来之后会被大量调用，EIP1167 并没什么优势
contract S11eProfileFactory is CloneFactory {
    //  the number of created profiles, auto counting
    uint256 public profileNums = 0;

    // profile num --> profile address
    mapping(uint256 => address) public profileAddresses;

    address public identityAddress;

    /**
     * @notice Event emitted when a new Profile has been created.
     * @param _address The Profile address.
     * @param _index The Profile name.
     */
    event CreatedEvent(address _address, uint256 _index);

    constructor(address _identityAddress) {
        require(
            _identityAddress != address(0),
            "identityAddress cannot be the zero address"
        );
        identityAddress = _identityAddress;
    }

    /**
     * @notice Creates and initializes a new profile with the Profile creator.
     * @notice Enters the new S11eDao in the ProfileFactory state.
     * @param _profileStruct The attribute of the Profile which, after being hashed, is used to access the address.
     * @param _owner The Profile's owner, who will be control the profile.
     */
    function createProfile(
        S11eProfile.ProfileStruct calldata _profileStruct,
        address _owner
    ) external {

    }

    /**
     * @notice Creates and initializes a new profile with the Profile creator by EIP1167 clone mode.
     * @notice Enters the new S11eDao in the ProfileFactory state.
     * @param _profileStruct The attribute of the Profile which, after being hashed, is used to access the address.
     * @param _owner The Profile's creator, who will be control the profile.
     */
    function cloneProfile(
        S11eProfile.ProfileStruct calldata _profileStruct,
        address _owner
    ) external {
        
    }

    /**
     * @notice Returns the Profile address based on its index.
     * @return The address of a Profile, given its index.
     * @param _index index of the Profile to be searched.
     */
    function getProfileAddressByIndex(
        uint256 _index
    ) external view returns (address) {
        return profileAddresses[_index];
    }
}
