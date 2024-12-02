// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

struct SavingsAccount {
    uint256 balance;
    address owner;
    uint256 creationTime;
    uint256 lockPeriod;
}

contract DecentralizedSavingsAccounts {
    mapping(address => SavingsAccount[]) public savingsPlans;

    event SavingsPlanCreated(
        address indexed owner,
        uint256 indexed planId,
        uint256 lockPeriod,
        uint256 amount
    );
    event FundsWithdrawn(
        address indexed receiver,
        uint256 indexed planId,
        uint256 amount
    );

    function createSavingsPlan(uint256 lockPeriodInDays) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        require(
            lockPeriodInDays > 0,
            "Lock period should be greater than zero"
        );

        uint256 lockPeriod = lockPeriodInDays * 1 days;

        SavingsAccount memory savingsAccount = SavingsAccount({
            balance: msg.value,
            owner: msg.sender,
            creationTime: block.timestamp,
            lockPeriod: lockPeriod
        });

        savingsPlans[msg.sender].push(savingsAccount);

        emit SavingsPlanCreated(
            msg.sender,
            savingsPlans[msg.sender].length - 1,
            lockPeriod,
            msg.value
        );
    }

    function viewSavingsPlan(uint256 savingsPlanId)
        external
        view
        returns (
            uint256 balance,
            address owner,
            uint256 creationTime,
            uint256 lockPeriod,
            uint256 timeLeft
        )
    {
        require(
            savingsPlanId < savingsPlans[msg.sender].length,
            "Invalid savings plan ID"
        );

        SavingsAccount memory savingsAccount = savingsPlans[msg.sender][savingsPlanId];

        timeLeft = block.timestamp >= savingsAccount.creationTime + savingsAccount.lockPeriod
            ? 0
            : savingsAccount.creationTime + savingsAccount.lockPeriod - block.timestamp;

        return (
            savingsAccount.balance,
            savingsAccount.owner,
            savingsAccount.creationTime,
            savingsAccount.lockPeriod,
            timeLeft
        );
    }

    function withdrawFunds(uint256 savingsPlanId) external {
        require(
            savingsPlanId < savingsPlans[msg.sender].length,
            "Invalid savings plan ID"
        );

        SavingsAccount storage savingsAccount = savingsPlans[msg.sender][savingsPlanId];

        require(
            savingsAccount.owner == msg.sender,
            "You are not the owner of this plan"
        );
        require(
            block.timestamp >= savingsAccount.creationTime + savingsAccount.lockPeriod,
            "Lock period has not expired"
        );
        require(savingsAccount.balance > 0, "No funds to withdraw");

        uint256 amountToWithdraw = savingsAccount.balance;
        savingsAccount.balance = 0;

        payable(msg.sender).transfer(amountToWithdraw);

        emit FundsWithdrawn(msg.sender, savingsPlanId, amountToWithdraw);
    }

    function getSavingsPlansCount() external view returns (uint256) {
        return savingsPlans[msg.sender].length;
    }
}
