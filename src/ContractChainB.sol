// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract ExecutableSampleChainB is AxelarExecutable {
    string public message;
    IAxelarGasService public immutable gasService;

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    // Handles calls created by setAndSend. Updates this contract's value
    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        // Decode the payload to retrieve the new message value
        string memory destinationChainC;
        string memory destinationAddressC;
        string memory messageTochainC;
        string memory destinationChainD;
        string memory destinationAddressD;
        string memory messageTochainD;

        (
            message,
            messageTochainC,
            destinationChainC,
            destinationAddressC,
            messageTochainD,
            destinationChainD,
            destinationAddressD
        ) = abi.decode(
            payload_,
            (string, string, string, string, string, string, string)
        );

        bytes memory payload = abi.encode(
            messageTochainC,
            messageTochainD,
            destinationChainD,
            destinationAddressD
        );

        gateway.callContract(destinationChainC, destinationAddressC, payload);
    }
}
