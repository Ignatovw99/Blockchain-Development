// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract MessageBoard {
    mapping(address => string[]) private usersMessages;

    function storeMessage(string calldata message) external {
        usersMessages[msg.sender].push(message);
    }

    function previewMessage(uint256 messageIndex) external view returns (string memory) {
        string[] memory userMessages = usersMessages[msg.sender];

        require(messageIndex < userMessages.length, "Message index out of bounds");

        string memory message = userMessages[messageIndex];
        return string(abi.encodePacked("Draft: ", message));
    }
}