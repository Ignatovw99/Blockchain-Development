// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "contracts/ERC20.sol";

/**
 * BrewBean, a popular coffee shop chain, is launching a loyalty program where customers earn "BrewBean Points" (BBP) with each purchase. To expand its rewards system, BrewBean partners with other cafes, each with its own rules for rewarding and redeeming points.
 * BrewBean’s loyalty program uses blockchain to create an ERC20-compliant BBP token and establishes a standardized interface that all partner cafes must follow.
 */

interface ILoyaltyPoints {

    event Rewarded(address indexed recipient, uint256 amount);
    
    event Redeemed(address indexed spender, uint256 amount);

    /**
     * @dev Rewards points to a specific customer.
     * @param recipient The address of the customer receiving the points.
     * @param amount The number of points to reward.
     */
    function rewardPoints(address recipient, uint256 amount) external;

    /**
     * @dev Allows a customer to redeem points.
     * @param spender The address of the customer redeeming the points.
     * @param amount The number of points to redeem.
     */
    function redeemPoints(address spender, uint256 amount) external;
}

abstract contract BaseLoyaltyProgram is MyToken, ILoyaltyPoints {
    
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) MyToken(name, symbol, decimals) {}

    function rewardPoints(address recipient, uint256 amount) public {
        require(_authorizeReward(recipient, amount), "Customer not eligible for reward");
        mint(recipient, amount);
        emit Rewarded(recipient, amount);
    }

    function redeemPoints(address spender, uint256 amount) public {
        // TODO;
    }

    function _authorizeReward(address customer, uint256 amount)
        internal
        view
        virtual
        returns (bool);
}
