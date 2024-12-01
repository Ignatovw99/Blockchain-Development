// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract GoalTracker {

    uint256 public goalAmount;
    uint256 public baseReward;
    uint256 public spendingTotal;
    bool public rewardClaimed;
    
    error InvalidOperation(string message);

    event SpendingAdded(uint256 amount, uint256 newTotal);
    event RewardClaimed(uint256 totalReward);

    constructor(uint256 _goalAmount, uint256 _baseReward) {
        require(_goalAmount > 0, "Goal amount must be greater than zero");
        require(_baseReward > 0, "Base reward must be greater than zero");

        goalAmount = _goalAmount;
        baseReward = _baseReward;
    }

    function addSpending(uint256 amount) public {
        require(amount > 0, "Spending amount must be greater than zero");

        spendingTotal += amount;
        emit SpendingAdded(amount, spendingTotal);
    }

    function claimReward() public returns (uint256 totalReward) {
        if (rewardClaimed) {
            revert InvalidOperation("Reward has already been claimed");
        }

        if (spendingTotal < goalAmount) {
            revert InvalidOperation("Goal has not been met");
        }

        rewardClaimed = true;

        for (uint256 i = 0; i < 5; i++) {
            totalReward += baseReward;
        }

        emit RewardClaimed(totalReward);
    }
}