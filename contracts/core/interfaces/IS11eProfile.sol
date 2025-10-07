// SPDx-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

pragma abicoder v2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "../../extensions/profileAssets/DigitalPoints.sol";
import "../../extensions/profileAssets/PFP.sol";
import "../../extensions/profileAssets/POAP.sol";
import "../../extensions/profileAssets/PassCard.sol";
import "../../erc6551/interfaces/IERC6551Registry.sol";

interface IS11eProfile {
    /**
     * @notice Types of assets that can be stored in this contract
     * @dev Profile type: BRAND-web3品牌  INDIVIDUAL-超级个体
     */
    enum ProfileType {
        NONE,
        BRAND,
        INDIVIDUAL
    }

    /**
     * @notice Types of assets that can be stored in this contract
     * @dev 品牌商户发行资产类型 1、数字徽章 2、PFP 3、数字积分 4、数字门票 5、pass卡
     */
    enum AssetsType {
        NONE,
        BADGE,
        PFP,
        DP,
        TICKET,
        PASSCARD
    }

    /** 
     * @notice The s11e procotol Profile Metadata Standards is a specification for describing profile metadata objects. 
               It is designed to describe the profile basic information
               https://docs.lens.xyz/docs/metadata-standards
     * @dev the meatdata is stored fully on-chain, and auto changed by the profile statues
     *
     * @param profileType the type of profile: individual|brand
     * @param name The name of profile.
     * @param symbol The symbol of profile.
     * @param memberNo the number of memebers(followed the profile)
     * @param owner The owner of profile.
     * @param baseURI The baseURI of profile.
     * @param erc6551Registry The erc6551Registry of profile.
     * @param externalUri The URI to be displayed for the profile NFT.
     */
    struct ProfileStruct {
        string profileType;
        string name;
        string symbol;
        uint256 memberNo;
        address owner;
        string baseURI;
        address erc6551Registry;
        string externalUri;
    }

    /**
     * @notice A struct containing profile data.
     *
     * @param name The name of assets
     * @param symbol The symbol of assets
     * @param supply The supply of assets
     * @param externalUri The URI to be displayed for the asset.
     */
    struct AssetsMetadataStruct {
        string name;
        string symbol;
        uint256 supply;
        string externalUri;
    }

    /**
     * @notice A struct containing profile data.
     *
     * @param protocol The protocol of assets: ERC20|ERC721|ERC1155
     * @param assetsType The type of assets @enum AssetsType
     * @param contractAddress The address of assets
     * @param name The name of assets
     * @param symbol The symbol of assets
     * @param supply The supply of assets
     * @param externalUri The URI to be displayed for the asset.
     */
    struct AssetsStruct {
        string protocol;
        uint8 assetsType;
        address contractAddress;
        string name;
        string symbol;
        uint256 supply;
        string externalUri;
    }

    /**
     * @notice post a digital assets collection base on s11eDao standard protocol, such as ERC20...
     * @dev
     * @param _assetsInfo The name of the DAO which, after being hashed, is used to access the address.
     */
    function collect(
        AssetsStruct memory _assetsInfo
    ) external returns (address);

    /**
     * @notice register a digital assets collection into profile
     * @dev
     * @param _assetsInfo The name of the DAO which, after being hashed, is used to access the address.
     */
    function register(AssetsStruct memory _assetsInfo) external;

    /**
     * @notice follow a profile
     * @dev call passCard assets contract of the profile to mint a NFT based on ERC6551 to customer
     * @param _memberAddress the address of member
     */
    function follow(address _memberAddress) external;

    /**
     * @notice follow a profile
     * @dev validate passCard NFT and join members
     */
    function follow() external;

    /**
     * @notice get members of profile
     * @dev
     * @param
     */
    function memberList() external view returns (address[] memory);

    /**
     * @notice the metadata of profile
     * @dev on-chain store the metadata
     * @return the metadata
     */
    //TODO: supplement metadata filed
    function profielMetadata() external view returns (string memory);

    /**
     * @notice the profile metadata of all assets
     * @dev on-chain store the metadata
     * @return the metadata
     */
    function assetsMetadata() external view returns (string memory);

    /**
     * @notice the address of index member
     * @return the metadata
     */
    function member(uint256 _index) external view returns (address);

    /**
     * @notice the address of passCard
     * @return the address
     */
    function passCard() external view returns (address);
}
