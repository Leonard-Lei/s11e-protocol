// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

contract Struct {

    struct ExtensionWrapperInialParam {
        bytes32 wrapperOrExtensionId;               //wrapper/extension 的ID
        address wrapperOrExtensionAddr;             //wrapper/extension 的address
        uint256 flags;
        bytes32[] keys;                             //
        uint256[] values;                           //插件地址
        address[] extensionAddresses;
        uint256[] extensionAclFlags;                //插件访问权限
    }

    struct BasicStruct {
        bytes32 wrapperOrExtensionId;               //wrapper/extension 的ID
        address wrapperOrExtensionAddr;             //wrapper/extension 的address
    }

    struct BasicTypeStruct {
        uint256 id;                                
        uint120 index;
    }       

    struct BasicAddressStruct {
        address addr;    
    }   


    struct BasicAddressesStruct {
        address[] addr;    
    } 

    struct BasicByte32Struct {
        bytes32 wrapperOrExtensionId;               //wrapper/extension 的ID
    }   

    struct BasicByte32sStruct {
        bytes32[] wrapperOrExtensionId;               //wrapper/extension 的IDs
    }   

    struct BasicUintsStruct {
        uint256[] id;                                 //
    }   



    mapping(uint256 => ExtensionWrapperInialParam) structStorage;
    mapping(uint256 => BasicStruct) basicStructStorage;
    mapping(uint256 => BasicTypeStruct) basicTypeStructStorage;
    mapping(uint256 => BasicAddressStruct) basicAddressStructStorage;
    mapping(uint256 => BasicAddressesStruct) basicAddressesStructStorage;
    mapping(uint256 => BasicByte32Struct) basicByte32StructStorage;
    mapping(uint256 => BasicByte32sStruct) basicByte32sStructStorage;
    
    BasicUintsStruct basicUintsStructStorage;

    address[] arrayAddressStorage;


    // Payable address can receive Ether
    address payable public owner;

    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }




    function writeBasicUintsStructStorage(BasicUintsStruct calldata _inialParam) external {
        basicUintsStructStorage = _inialParam;
    }



    function writeAddressArray(address[] calldata _inialParam) external {
        arrayAddressStorage = _inialParam;
    }


    function readAddressArray() external view returns ( address[] memory) {
        return arrayAddressStorage;
    }
     

    function writeStruct(ExtensionWrapperInialParam calldata _inialParam) external {
        structStorage[1].wrapperOrExtensionId = _inialParam.wrapperOrExtensionId;
        structStorage[1].wrapperOrExtensionAddr = _inialParam.wrapperOrExtensionAddr;
        structStorage[1].flags = _inialParam.flags;
        structStorage[1].keys = _inialParam.keys;
        structStorage[1].values = _inialParam.values;
        structStorage[1].extensionAddresses = _inialParam.extensionAddresses;
        structStorage[1].extensionAclFlags = _inialParam.extensionAclFlags;
    }


        

    function writeMultiStruct(
        bytes32 wrapperOrExtensionId,
        address wrapperOrExtensionAddr,
        uint128 flags,        
        bytes32[] calldata keys,     
        uint256[] calldata values,        
        address[] calldata extensionAddresses,
        uint128[] calldata extensionAclFlags) external {
        structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId;
        structStorage[1].wrapperOrExtensionAddr = wrapperOrExtensionAddr;
        structStorage[1].flags = flags;
        structStorage[1].keys = keys;
        structStorage[1].values = values;
        structStorage[1].extensionAddresses = extensionAddresses;
        structStorage[1].extensionAclFlags = extensionAclFlags;
    }


    function writeMultiParam(
        bytes32 wrapperOrExtensionId,
        address wrapperOrExtensionAddr,
        uint128 flags,        
        bytes32 keys,     
        uint256 values,        
        address extensionAddresses,
        uint128 extensionAclFlags) external {
        // structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId;
        // structStorage[1].wrapperOrExtensionAddr = wrapperOrExtensionAddr;
        // structStorage[1].flags = flags;
        // structStorage[1].keys[0] = keys;
        // structStorage[1].values[0] = values;
        // structStorage[1].extensionAddresses[0] = extensionAddresses;
        // structStorage[1].extensionAclFlags[0] = extensionAclFlags;
    }

    function writeMultiParam1(
        bytes32 wrapperOrExtensionId,
        address wrapperOrExtensionAddr) external {
        structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId;
        structStorage[1].wrapperOrExtensionAddr = wrapperOrExtensionAddr;
        // structStorage[1].flags = flags;
    }

    function writeMultiParam2(
        bytes32 wrapperOrExtensionId1,
        bytes32 wrapperOrExtensionId12) external {
        structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId1;
        structStorage[2].wrapperOrExtensionId = wrapperOrExtensionId12;
        // structStorage[1].flags = flags;
    }


    function writeMultiParam3(
        bytes32 wrapperOrExtensionId1,
        bytes32 wrapperOrExtensionId12,
        bytes32 wrapperOrExtensionId13
        ) external {
        structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId1;
        structStorage[2].wrapperOrExtensionId = wrapperOrExtensionId12;
        structStorage[3].wrapperOrExtensionId = wrapperOrExtensionId13;
        // structStorage[1].flags = flags;
    }


    function writeMultiParam5(
        bytes32 wrapperOrExtensionId1,
        bytes32 wrapperOrExtensionId12,
        bytes32 wrapperOrExtensionId13,
        bytes32 wrapperOrExtensionId14,
        bytes32 wrapperOrExtensionId15
        ) external {
        structStorage[1].wrapperOrExtensionId = wrapperOrExtensionId1;
        structStorage[2].wrapperOrExtensionId = wrapperOrExtensionId12;
        structStorage[3].wrapperOrExtensionId = wrapperOrExtensionId13;
        structStorage[4].wrapperOrExtensionId = wrapperOrExtensionId14;
        structStorage[5].wrapperOrExtensionId = wrapperOrExtensionId15;
        // structStorage[1].flags = flags;
    }

    function writeBasicStruct(BasicStruct calldata _inialParam) external {
        basicStructStorage[1].wrapperOrExtensionId = _inialParam.wrapperOrExtensionId;
        basicStructStorage[1].wrapperOrExtensionAddr = _inialParam.wrapperOrExtensionAddr;
    }


    function writeBasicTypeStruct(BasicTypeStruct calldata _inialParam) external {
        basicTypeStructStorage[1].id = _inialParam.id;
        basicTypeStructStorage[1].index = _inialParam.index;
    }


    function writeBasicAddressStruct(BasicAddressStruct calldata _inialParam) external {
        basicAddressStructStorage[1].addr = _inialParam.addr;
    }


    function writeBasicAddressesStruct(BasicAddressesStruct calldata _inialParam) external {
        basicAddressesStructStorage[1].addr = _inialParam.addr;
    }


    function writeBasicByte32Struct(BasicByte32Struct calldata _inialParam) external {
        basicByte32StructStorage[1].wrapperOrExtensionId = _inialParam.wrapperOrExtensionId;
    }


    function writeBasicBytes32Struct(BasicByte32sStruct calldata _inialParam) external {
        basicByte32sStructStorage[1].wrapperOrExtensionId = _inialParam.wrapperOrExtensionId;
    }

    function readStruct(uint256 _index) external view returns (ExtensionWrapperInialParam memory) {
        return structStorage[_index];
    }


    function readBasicStruct(uint256 _index) external view returns (BasicStruct memory) {
        return basicStructStorage[_index];
    }


    function readBasicTypeStruct(uint256 _index) external view returns (BasicTypeStruct memory) {
        return basicTypeStructStorage[_index];
    }

  function readBasicAddressStruct(uint256 _index) external view returns (BasicAddressStruct memory) {
        return basicAddressStructStorage[_index];
    }

  function readBasicAddressesStruct(uint256 _index) external view returns (BasicAddressesStruct memory) {
        return basicAddressesStructStorage[_index];
    }

  function readBasicByte32Struct(uint256 _index) external view returns (BasicByte32Struct memory) {
        return basicByte32StructStorage[_index];
    }

  function readBasicByte32sStruct(uint256 _index) external view returns (BasicByte32sStruct memory) {
        return basicByte32sStructStorage[_index];
    }


    function readBasicUintsStructStorage() external view returns (BasicUintsStruct memory)  {
        return basicUintsStructStorage;
    }

}