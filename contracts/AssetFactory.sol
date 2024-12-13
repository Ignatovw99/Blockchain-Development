// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Asset {
    string public ticker;
    string public name;
    uint256 public totalSupply;
    mapping(address => uint256) balances;

    constructor(
        string memory _ticker,
        string memory _name,
        uint256 initialSupply,
        address creator
    ) {
        ticker = _ticker;
        name = _name;
        totalSupply = initialSupply;
        balances[creator] = initialSupply;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract AssetProxy {
    address public asset;

    constructor(address _asset) {
        asset = _asset;
    }

    function transferAsset(address to, uint256 amount) external returns (bool) {
        (bool success, ) = asset.delegatecall(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success, "Transfer failed");

        return true;
    }
}

contract AssetFactory {
    mapping(string => address) assetAddresses;

    event AssetCreated(string indexed ticker, address assetAddress);
    event AssetTransfered(
        string indexed ticker,
        address from,
        address to,
        uint256 amount
    );

    function createAsset(
        string memory ticker,
        string memory name,
        uint256 initialSupply
    ) external {
        require(assetAddresses[ticker] == address(0), "Asset already exists");

        Asset asset = new Asset(ticker, name, initialSupply, msg.sender);
        assetAddresses[ticker] = address(asset);

        emit AssetCreated(ticker, address(asset));
    }

    function getAssetAddress(string memory ticker)
        external
        view
        returns (address)
    {
        return assetAddresses[ticker];
    }

    function transferAsset(
        string memory ticker,
        address to,
        uint256 amount
    ) external returns (bool) {
        address assetAddress = assetAddresses[ticker];
        require(assetAddress != address(0), "Asset does not exist");

        AssetProxy assetProxy = new AssetProxy(assetAddress);
        bool success = assetProxy.transferAsset(to, amount);

        emit AssetTransfered(ticker, msg.sender, to, amount);

        return success;
    }
}
