// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract ExecutableSampleChainG is AxelarExecutable {
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

        (message, messageTochainC, destinationChainC, destinationAddressC) = abi
            .decode(payload_, (string, string, string, string));

        bytes memory payload = abi.encode(messageTochainC);

        gasService.payGas{value: address(this).balance}(
            address(this),
            destinationChainC,
            destinationAddressC,
            payload,
            300_000,
            false,
            address(this),
            new bytes(0)
        );

        gateway.callContract(destinationChainC, destinationAddressC, payload);
    }
}
