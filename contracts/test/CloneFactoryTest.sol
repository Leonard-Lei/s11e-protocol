// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

import "../utils/CloneFactory.sol";

contract CloneFactoryTest is CloneFactory {
    address public identityAddress;
    /**
     * @notice Event emitted when a new contract has been created.
     * @param contractAddress The DAO address.
     */
    event CreatedEvent(address contractAddress);

    constructor(address _identityAddress) {
        identityAddress = _identityAddress;
    }

    function create() external {
        address contractAddress = _createClone(identityAddress);
        //slither-disable-next-line reentrancy-events
        emit CreatedEvent(contractAddress);
    }
}
