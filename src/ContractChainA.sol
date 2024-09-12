// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract ExecutableSampleChainA is AxelarExecutable {
    string public message;
    IAxelarGasService public immutable gasService;

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    // Call this function to send a message to chain destinationChain and destinationAddress.
    // Also send send the information to chain destinationChainC and destinationAddressC in order to send a message to chain C from chain B
    function sendMessage(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata messageToSend,
        uint gasLimit,
        string calldata destinationChainC,
        string calldata destinationAddressC,
        string calldata messageTochainC
    ) external payable {
        require(msg.value > 0, "Gas payment is required");

        bytes memory payload = abi.encode(
            messageToSend,
            messageTochainC,
            destinationChainC,
            destinationAddressC
        );
        _payGasAndExecuteCall(
            destinationChain,
            destinationAddress,
            payload,
            gasLimit
        );
    }

    // I added this internal function to handle stack too deep error
    function _payGasAndExecuteCall(
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes memory payload,
        uint gasLimit
    ) internal override {
        gasService.payGas{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            gasLimit,
            false,
            msg.sender,
            new bytes(0)
        );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }
}
