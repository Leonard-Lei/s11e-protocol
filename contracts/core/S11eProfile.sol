// SPDx-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

pragma abicoder v2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "../extensions/profileAssets/DigitalPoints.sol";
import "../extensions/profileAssets/PFP.sol";
import "../extensions/profileAssets/POAP.sol";
import "../extensions/profileAssets/PassCard.sol";
import "../extensions/profileAssets/interfaces/IPassCard.sol";
import "../erc6551/interfaces/IERC6551Registry.sol";
import "./interfaces/IS11eProfile.sol";
import "../utils/StringsUtils.sol";

/**
 * @dev s11e-protocol profile contract
 * 1.post|publish|collect digital assets、pass card and register
 * 2.register external assets
 * 3.follow other profile
 * 4.whitelist manager
 * 5.member manager
 * 6.assets manager
 * 7.follow relationship manager
 */
contract S11eProfile is IS11eProfile, AccessControl {
    using Strings for uint256;
    using StringsUtils for string;
    // using Strings for address;

    address[] public members;
    uint256 public assetsCount;
    uint256 public membersCount;
    mapping(address => bool) public membersMapping;
    mapping(address => bool) public blacklist;

    ProfileStruct public profile;

    // erc6551 registry contract address
    IERC6551Registry public erc6551Registry;
    string public baseURI;
    /**
     * @dev passCard cntract address
     */
    address public passCardAddress;

    /**
     * @notice the assets information of collected by the profile
     * @dev index => contractAddress
     */
    mapping(uint256 => AssetsStruct) public assetsCollection;
    mapping(uint256 => address) public assetsAddress;

    /**
     * @dev Allows all Ether transfers
     */
    receive() external payable virtual {}

    event CollectAssetsEvent(uint256 _assetsCount, AssetsStruct _assetsInfo);
    event RegisterAssetsEvent(uint256 _assetsCount, AssetsStruct _assetsInfo);
    event UpdateProfileEvent(ProfileStruct _profileStruct);
    event FollowEvent(uint256 _membersCount, address _memberAddress);

    constructor(ProfileStruct memory _profileStruct) {
        assetsCount = 0;
        membersCount = 0;
        profile = _profileStruct;
        erc6551Registry = IERC6551Registry(_profileStruct.erc6551Registry);
        baseURI = _profileStruct.baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, _profileStruct.owner);
    }

    /**
     * @notice update profile basic information.
     * @param _profileStruct the information of profile.
     */
    function updateProfile(ProfileStruct memory _profileStruct) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have owner role"
        );
        if (bytes(_profileStruct.profileType).length > 0) {
            profile.profileType = _profileStruct.profileType;
        }
        if (bytes(_profileStruct.name).length > 0) {
            profile.name = _profileStruct.name;
        }
        if (bytes(_profileStruct.symbol).length > 0) {
            profile.symbol = _profileStruct.symbol;
        }
        if (bytes(_profileStruct.baseURI).length > 0) {
            profile.baseURI = _profileStruct.baseURI;
        }
        if (_profileStruct.erc6551Registry != address(0)) {
            profile.erc6551Registry = _profileStruct.erc6551Registry;
        }
        if (bytes(_profileStruct.externalUri).length > 0) {
            profile.externalUri = _profileStruct.externalUri;
        }
        emit UpdateProfileEvent(_profileStruct);
    }

    /**
     * @notice post a digital assets collection base on s11eDao standard protocol, such as ERC20...
     * @dev
     * @param _assetsInfo The name of the DAO which, after being hashed, is used to access the address.
     */
    function collect(
        AssetsStruct memory _assetsInfo
    ) external returns (address) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have owner role"
        );
        // create a new asset contract
        address assetsAddress_;
        if (AssetsType(_assetsInfo.assetsType) == AssetsType.PASSCARD) {
            // PassCard asset = new PassCard{value: msg.value}();
            PassCard passCard_ = new PassCard(
                _assetsInfo.name,
                _assetsInfo.symbol,
                baseURI,
                _assetsInfo.supply,
                (address)(erc6551Registry),
                _msgSender()
            );
            assetsAddress_ = address(passCard_);
            passCard_.grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
            passCardAddress = assetsAddress_;
        } else if (AssetsType(_assetsInfo.assetsType) == AssetsType.DP) {
            DigitalPoints digitalPoints_ = new DigitalPoints(
                _assetsInfo.name,
                _assetsInfo.symbol,
                _assetsInfo.supply,
                _msgSender()
            );
            assetsAddress_ = address(digitalPoints_);
            digitalPoints_.grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        }
        _assetsInfo.contractAddress = assetsAddress_;
        assetsCollection[assetsCount] = _assetsInfo;
        assetsAddress[assetsCount] = assetsAddress_;
        emit CollectAssetsEvent(assetsCount, _assetsInfo);
        assetsCount++;
        return assetsAddress_;
    }

    /**
     * @notice register a digital assets collection into profile
     * @dev
     * @param _assetsInfo The name of the DAO which, after being hashed, is used to access the address.
     */
    function register(AssetsStruct memory _assetsInfo) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have owner role"
        );
        assetsCollection[assetsCount] = _assetsInfo;
        emit RegisterAssetsEvent(assetsCount, _assetsInfo);
        assetsCount++;
    }

    /**
     * @notice follow a profile
     * @dev validate passCard NFT and join members
     * @param _memberAddress the address of member
     */
    function follow(address _memberAddress) external {
        IPassCard passCard_ = IPassCard(passCardAddress);
        require(
            passCard_.balanceOf(_memberAddress) > 0,
            "must hold passCard at least one"
        );
        members.push(_memberAddress);
        emit FollowEvent(membersCount, _memberAddress);
        membersCount++;
    }

    /**
     * @notice follow a profile
     * @dev validate passCard NFT and join members
     */
    function follow() external {
        IPassCard passCard_ = IPassCard(passCardAddress);
        require(
            passCard_.balanceOf(_msgSender()) > 0,
            "must hold passCard at least one"
        );
        members.push(_msgSender());
        emit FollowEvent(membersCount, _msgSender());
        membersCount++;
    }

    /**
     * @notice get members of profile
     * @dev
     * @param
     */
    function memberList() external view returns (address[] memory) {
        return members;
    }

    /**
     * @notice the metadata of profile
     * @dev on-chain store the metadata
     * @return the metadata
     */
    //TODO: supplement metadata filed
    function profielMetadata() external view returns (string memory) {
        // string memory image = Base64.encode(bytes(generateSVGImage(tokenId)));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                profile.name,
                                '", "symbol":"',
                                profile.symbol,
                                '", "memberNo":"',
                                profile.memberNo.toString(),
                                '", "profileType":"',
                                profile.profileType,
                                '", "assets":[',
                                assetsEncode(),
                                "]}"
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice the metadata of all assets
     * @dev on-chain store the metadata
     * @return the metadata
     */
    function assetsMetadata() external view returns (string memory) {
        string memory ret;
        ret = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(abi.encodePacked('{"assets":[', assetsEncode(), "]}"))
                )
            )
        );
        return ret;
    }

    /**
     * @notice the address of index member
     * @return the metadata
     */
    function member(uint256 _index) external view returns (address) {
        return members[_index];
    }

    /**
     * @notice the address of passCard
     * @return the metadata
     */
    function passCard() external view returns (address) {
        return passCardAddress;
    }

    /**
     * @notice the metadata of assets
     * @dev Combine all the SVGs to generate the final image
     * @return the metadata
     */
    function generateSVGImage() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    abi.encodePacked(
                        generateSVGHead(),
                        // getFestivalDetailSVG(),
                        "</svg>"
                    )
                )
            );
    }

    /**
     * @notice
     * @dev  generate SVG header
     * @return the metadata
     */
    function generateSVGHead() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"',
                    ' viewBox="0 0 216 307.2" style="enable-background:new 0 0 216 307.2;" xml:space="default">'
                )
            );
    }

    /**
     * @notice
     * @dev Combine all the SVGs to generate the final image
     * @return the metadata
     */
    function generateSVGFoot() internal pure returns (string memory) {
        return string(abi.encodePacked("</svg>"));
    }

    function addressToString(
        address addr
    ) internal pure returns (string memory) {
        //Convert addr to bytes
        bytes20 value = bytes20(uint160(addr));
        bytes memory strBytes = new bytes(42);
        //Encode hex prefix
        strBytes[0] = "0";
        strBytes[1] = "x";
        //Encode bytes usig hex encoding
        for (uint i = 0; i < 20; i++) {
            uint8 byteValue = uint8(value[i]);
            strBytes[2 + (i << 1)] = encode((byteValue >> 4) & 0x0f);
            strBytes[3 + (i << 1)] = encode(byteValue & 0x0f);
        }
        return string(strBytes);
    }

    function assetsEncode() internal view returns (string memory) {
        string memory ret;
        for (uint256 i = 0; i < assetsCount; i++) {
            if (i + 1 < assetsCount) {
                ret = string(
                    abi.encodePacked(
                        ret,
                        '{"protocol":"',
                        assetsCollection[i].protocol,
                        '", "assetsType":"',
                        ((uint256)(assetsCollection[i].assetsType)).toString(),
                        '", "contractAddress":"',
                        addressToString(assetsCollection[i].contractAddress),
                        '", "metadata":{"name":"',
                        assetsCollection[i].name,
                        '", "symbol":"',
                        assetsCollection[i].symbol,
                        '", "supply":"',
                        assetsCollection[i].supply.toString(),
                        '", "externalUri":"',
                        assetsCollection[i].externalUri,
                        '"}},'
                    )
                );
            } else {
                ret = string(
                    abi.encodePacked(
                        ret,
                        '{"protocol":"',
                        assetsCollection[i].protocol,
                        '", "assetsType":"',
                        ((uint256)(assetsCollection[i].assetsType)).toString(),
                        '", "contractAddress":"',
                        addressToString(assetsCollection[i].contractAddress),
                        '", "metadata":{"name":"',
                        assetsCollection[i].name,
                        '", "symbol":"',
                        assetsCollection[i].symbol,
                        '", "supply":"',
                        assetsCollection[i].supply.toString(),
                        '", "externalUri":"',
                        assetsCollection[i].externalUri,
                        '"}}'
                    )
                );
            }
        }
        return ret;
    }

    //-----------HELPER METHOD--------------//

    //num represents a number from 0-15 and returns ascii representing [0-9A-Fa-f]
    function encode(uint8 num) private pure returns (bytes1) {
        //0-9 -> 0-9
        if (num >= 0 && num <= 9) {
            return bytes1(num + 48);
        }
        //10-15 -> a-f
        return bytes1(num + 87);
    }

    //asc represents one of the char:[0-9A-Fa-f] and returns consperronding value from 0-15
    function decode(bytes1 asc) private pure returns (uint8) {
        uint8 val = uint8(asc);
        //0-9
        if (val >= 48 && val <= 57) {
            return val - 48;
        }
        //A-F
        if (val >= 65 && val <= 70) {
            return val - 55;
        }
        //a-f
        return val - 87;
    }
}
