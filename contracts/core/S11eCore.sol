// SPDx-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

import "./S11eProfileFactory.sol";
import "./interfaces/IS11eProfile.sol";

// import "./S11eDaoFactory.sol";

/**
 * @dev s11e-protocol core contract
 * 1.create any profile
 * 2.create any dao
 * 3.manage profile
 * 4.manage dao
 */
contract S11eCore is AccessControl {
    using Strings for uint256;

    // erc6551 registry contract address
    IERC6551Registry public erc6551Registry;
    string public baseURI;
    uint256 public profileCount;
    uint256 public daoCount;
    // profile num --> profile address
    mapping(uint256 => address) public profileAddresses;

    S11eProfileFactory s11eProfileFactory;

    // S11eDaoFactory s11eDaoFactory;

    event CreateProfileEvent(
        uint256 _profileCount,
        IS11eProfile.ProfileStruct _profileStruct
    );
    // event CreateDaoEvent(uint256 _daoCount, AssetsStruct _assetsInfo);
    event UpdateS11eProfileFactoryEvent(address _s11eProfileFactoryAddress);

    constructor(string memory _baseURI, address _erc6551Registry) {
        profileCount = 0;
        baseURI = _baseURI;
        erc6551Registry = IERC6551Registry(_erc6551Registry);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev create a new profile
     */
    function createProfile(
        IS11eProfile.ProfileStruct memory _profileStruct
    ) external returns (address) {
        _profileStruct.owner = _msgSender();
        _profileStruct.erc6551Registry = address(erc6551Registry);
        _profileStruct.baseURI = baseURI;
        S11eProfile s11eProfile_ = new S11eProfile(_profileStruct);
        profileAddresses[profileCount] = (address)(s11eProfile_);

        // s11eProfileFactory.createProfile(_profileStruct, _msgSender());
        emit CreateProfileEvent(profileCount, _profileStruct);
        profileCount++;
        return (address)(s11eProfile_);
    }

    /**
     * @dev create a new dao
     */
    function createDao() external {}

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

    /**
     * @notice set S11eProfileFactory address.
     * @param _s11eProfileFactory the address of S11eProfileFactory address.
     */
    function setS11eProfileFactory(address _s11eProfileFactory) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have owner role"
        );
        s11eProfileFactory = S11eProfileFactory(_s11eProfileFactory);
        emit UpdateS11eProfileFactoryEvent(_s11eProfileFactory);
    }

    /**
     * @notice set S11eProfileFactory address.
     * @param _s11eDaoFactory the address of S11eDaoFactory address.
     */
    // function setS11eDaoFactory(address _s11eDaoFactory) external {
    //     require(
    //         hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
    //         "must have owner role"
    //     );
    //     s11eDaoFactory = S11eDaoFactory(_s11eDaoFactory);
    // }
}
