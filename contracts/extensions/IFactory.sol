// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

interface IFactory {
    function getExtensionAddress(
        address _dao,
        bytes32 _extensionId
    ) external view returns (address);
}
