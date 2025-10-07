
    //SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;


import "hardhat/console.sol";

abstract contract S11eAcl {

    struct Wrapper {
        bytes32 id;
        address addr;
        uint128 flags;
    }

    enum MemberFlag {
        EXISTS,
        JAILED
    }

    enum ProposalFlag {
        EXISTS, //存在
        SPONSORED, //赞助
        PROCESSED //已经处理
    }

    enum TaskFlag {
        EXISTS, //存在
        BOUNTIED, //已经寻赏
        PROCESSED //已经处理
    }

    enum AclFlag {
        REPLACE_WRAPPER, //替换包装器
        SUBMIT_PROPOSAL, //提交提案
        UPDATE_DELEGATE_KEY, //更新代表钥匙
        SET_CONFIGURATION, //设置配置
        ADD_EXTENSION, //添加扩展
        REMOVE_EXTENSION, //移除扩展
        ADD_WRAPPER, //添加装饰器
        REMOVE_WRAPPER, //移除装饰器
        NEW_MEMBER, //添加新成员
        JAIL_MEMBER, //监禁成员
        CREATE_TASK, //创建任务
        REMOVE_TASK //移除任务
    }

    enum TreasuryExtAclFlag {
        ADD_TO_BALANCE,
        SUB_FROM_BALANCE,
        INTERNAL_TRANSFER,
        WITHDRAW,
        REGISTER_NEW_TOKEN,
        REGISTER_NEW_INTERNAL_TOKEN,
        UPDATE_TOKEN
    }

    enum VaultsExtAclFlag {
        WITHDRAW_NFT,
        COLLECT_NFT,
        INTERNAL_TRANSFER
    }

    enum ERC777TokenExtAclFlag {
        WITHDRAW_NFT,
        COLLECT_NFT,
        INTERNAL_TRANSFER
    }

    enum InternalTokenVestingExtAclFlag {
        NEW_VESTING,
        REMOVE_VESTING
    }

    enum ERC1155TokenExtAclFlag {
        WITHDRAW_NFT,
        COLLECT_NFT,
        INTERNAL_TRANSFER
    }

    // 联合曲线类型
    enum ContinuosCurveType {
        BANCOR_CURVE,
        BONDING_CURVE
    }


    struct ExtensionWrapperInialParam {
        bytes32 wrapperOrExtensionId;               //wrapper/extension 的ID
        address wrapperOrExtensionAddr;             //wrapper/extension 的address
        uint256 flags;
        bytes32[] keys;                             //
        uint256[] values;                           //插件地址
        address[] extensionAddresses;
        uint256[] extensionAclFlags;                //插件访问权限
    }



    struct WrapperEntry {
        bytes32 id;
        uint256 acl;
    }

    struct ExtensionEntry {
        bytes32 id;
        mapping(address => uint256) acl;
        bool deleted;
    }


    enum DaoState {
        CREATION,
        READY
    }

    /*
     * STRUCTURES
     */
    struct Proposal {
        // the structure to track all the proposals in the DAO
        address wrapperAddress; // the wrapper address that called the functions to change the DAO state
        uint256 flags; // flags to track the state of the proposal: exist, sponsored, processed, canceled, etc.
    }

    struct Task {
        // the structure to track all the tasks in the DAO
        address wrapperAddress; // the wrapper address that called the functions to change the DAO state
        uint256 flags; // flags to track the state of the proposal: exist, sponsored, processed, canceled, etc.
    }

    struct Member {
        // the structure to track all the members in the DAO
        uint256 flags; // flags to track the state of the member: exists, etc
    }

    struct Checkpoint {
        // A checkpoint for marking number of votes from a given block
        uint96 fromBlock;
        uint160 amount;
    }

    struct DelegateCheckpoint {
        // A checkpoint for marking the delegate key for a member from a given block
        uint96 fromBlock;
        address delegateKey;
    }


    //manager wrapper
    enum ManagerUpdateType {
        UNKNOWN,
        ADAPTER,
        EXTENSION,
        CONFIGS
    }

    enum ManagerConfigType {
        NUMERIC,
        ADDRESS
    }

    struct ManagerConfiguration {
        bytes32 key;
        uint256 numericValue;
        address addressValue;
        ManagerConfigType configType;
    }

    struct ManagerProposalDetails {
        bytes32 wrapperOrExtensionId;
        address wrapperOrExtensionAddr;
        ManagerUpdateType updateType;
        uint128 flags;
        bytes32[] keys;
        uint256[] values;
        address[] extensionAddresses;
        uint128[] extensionAclFlags;
    }

    struct ManagerManagingCoupon {
        address daoAddress;
        ManagerProposalDetails proposal;
        ManagerConfiguration[] configs;
        uint256 nonce;
    }

    // HoldShareOnboardingWrapper
    enum HoldShareOnboardingWrapperHoldTokenType {
        ERC20,
        ERC721,
        ERC1155,
        ERC3525
    }


    // onboarding wrapper
    struct OnboardingWrapperProposalDetails {
        bytes32 id;
        address addressToMint;
        uint160 amount;
        uint88 unitsRequested;
        address token;
        address payable applicant;
    }

    struct OnboardingWrapperOnboardingDetails {
        uint88 chunkSize;
        uint88 numberOfChunks;
        uint88 unitsPerChunk;
        uint88 unitsRequested;
        uint96 totalUnits;
        uint160 amount;
    }


    // voting wrapper
     struct VotingWrapperVoting {
        uint256 nbYes;
        uint256 nbNo;
        uint256 startingTime;
        uint256 blockNumber;
        mapping(address => uint256) votes;
    }

    // offchain voting
     struct OffchainVotingProposalChallenge {
        address reporter;
        uint256 units;
    }

    struct OffchainVotingVoting {
        uint256 snapshot;
        address reporter;
        bytes32 resultRoot;
        uint256 nbYes;
        uint256 nbNo;
        uint64 startingTime;
        uint64 gracePeriodStartingTime;
        bool isChallenged;
        bool forceFailed;
        uint256 nbMembers;
        uint256 stepRequested;
        uint256 fallbackVotesCount;
        mapping(address => bool) fallbackVotes;
    }

    struct OffchainVotingVotingDetails {
        uint256 snapshot;
        address reporter;
        bytes32 resultRoot;
        uint256 nbYes;
        uint256 nbNo;
        uint256 startingTime;
        uint256 gracePeriodStartingTime;
        bool isChallenged;
        uint256 stepRequested;
        bool forceFailed;
        uint256 fallbackVotesCount;
    }


    // offchain voting hash
    struct OffChainVotingHashVoteStepParams {
        uint256 previousYes;
        uint256 previousNo;
        bytes32 proposalId;
    }

    struct OffChainVotingHashVoteResultNode {
        uint32 choice;
        uint64 index;
        uint64 timestamp;
        uint88 nbNo;
        uint88 nbYes;
        bytes sig;
        bytes32 proposalId;
        bytes32[] proof;
    }

}