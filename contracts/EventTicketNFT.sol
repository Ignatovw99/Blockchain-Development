// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/*
 * NFT-Based Ticketing System
 * Event management platform that issues NFT-based tickets for exclusive concerts and events.
 * Each ticket is represented as a unique NFT on the blockchain, acting as proof of attendance and granting entry to the event.
 * Unlike traditional tickets, these NFT tickets are secure, transferable, and verifiable.
 * Ticket holders can retain their NFTs as digital collectibles or trade them on secondary markets.
 */

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);
}

contract EventTicketNFT is IERC721 {
    string public name = "EventTicketNFT";
    string public symbol = "ETN";

    uint256 private _currentTokenId;

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(uint256 => string) private _tokenURIs;

    address public owner;

    event TicketMinted(
        address indexed buyer,
        uint256 indexed ticketId,
        string metadataURI
    );

    constructor() {
        owner = msg.sender;
        _currentTokenId = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the contract owner");
        _;
    }

    function balanceOf(address ownerAddress) public view returns (uint256) {
        require(
            ownerAddress != address(0),
            "Address zero is not a valid owner"
        );
        return _balances[ownerAddress];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(from == _owners[tokenId], "Transfer not authorized by owner");
        require(to != address(0), "Cannot send token to the zero address");
        require(
            msg.sender == from || msg.sender == _tokenApprovals[tokenId],
            "Caller is not authorized to transfer this token"
        );

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        address tokenOwner = _owners[tokenId];
        require(msg.sender == tokenOwner, "Caller is not the token owner");
        require(to != tokenOwner, "Cannot approve the current owner");

        _tokenApprovals[tokenId] = to;

        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    function mintToken(
        address buyer,
        string calldata eventName,
        string calldata eventDate,
        string calldata seatNumber
    ) public onlyOwner {
        _currentTokenId++;
        uint256 ticketId = _currentTokenId;

        string memory metadataURI = string(
            abi.encodePacked(
                "data:application/json;utf8,",
                "{\"name\":\"", eventName, "\",",
                "\"date\":\"", eventDate, "\",",
                "\"seat\":\"", seatNumber, "\",",
                "\"description\":\"Ticket for ", eventName, "\",",
                "\"image\":\"https://example.com/images/", toString(ticketId), ".png\"}"
            )
        );

        _balances[buyer] += 1;
        _owners[ticketId] = buyer;
        _tokenURIs[ticketId] = metadataURI;

        emit TicketMinted(buyer, ticketId, metadataURI);
        emit Transfer(address(0), buyer, ticketId);
    }

    function getTicketMetadata(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
