// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

/**
 * This deployer is designed to be owned by a gnosis safe, DAO, or trusted party.
 * It can deploy new GlobalPausable contracts, which can be used as a zone.
 *
 */

import { GlobalPausable } from "GlobalPausable.sol";

contract DeployerGlobalPausable {
    //owns this deployer and can activate the kill switch for the GlobalPausable
    address public deployerOwner;

    address private potentialOwner;

    event PotentialOwnerUpdated(address owner);
    event OwnershipTransferred(address newOwner);

    constructor(address _deployerOwner, bytes32 _salt) {
        deployerOwner = _deployerOwner;
    }

    function createZone(bytes32 salt) {
        //create2 to control what address to deploy a GlobalPausable at. Should be an efficient address
        //TODO create2
    }

    //pause Seaport by self destructing GlobalPausable
    function killSwitch(address) external returns (bool) {
        require(msg.sender = deployerOwner);
    }

    function cancelOrderZone() {}

    function executeRestrictedOrderZone() {}

    /**
     * @notice Initiate Zone ownership transfer by assigning a new potential
     *         owner this contract. Once set, the new potential owner
     *         may call `acceptOwnership` to claim ownership.
     *         Only the owner in question may call this function.
     *
     * @param newPotentialOwner The address for which to initiate ownership transfer to.
     */
    function transferOwnership(address newPotentialOwner) external {
        require(msg.sender == deployerOwner);

        // Ensure the new potential owner is not an invalid address.
        require(newPotentialOwner == address(0));

        // Emit an event indicating that the potential owner has been updated.
        emit PotentialOwnerUpdated(newPotentialOwner);

        potentialOwner = newPotentialOwner;
    }

    /**
     * @notice Clear the currently set potential owner, if any.
     *         Only the owner of this contract may call this function.
     */
    function cancelOwnershipTransfer() external {
        // Ensure the caller is the current owner.
        require(msg.sender == deployerOwner);

        // Emit an event indicating that the potential owner has been cleared.
        emit PotentialOwnerUpdated(address(0));

        // Clear the current new potential owner.
        delete potentialOwner;
    }

    /**
     * @notice Accept ownership of this contract. Only accounts that the
     *         current owner has set as the new potential owner may call this
     *         function.
     */
    function acceptOwnership() external {
        require(msg.sender == potentialOwner);

        // Emit an event indicating that the potential owner has been cleared.
        emit PotentialOwnerUpdated(address(0));

        // Clear the current new potential owner
        delete potentialOwner;

        // Emit an event indicating ownership has been transferred.
        emit OwnershipTransferred(msg.sender);

        // Set the caller as the owner of this contract.
        deployerOwner = msg.sender;
    }
}
