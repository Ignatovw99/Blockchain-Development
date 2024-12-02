// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

struct Campaign {
    address payable creator;
    uint256 goal;
    uint256 deadline;
    uint256 totalFunds;
    bool fundsClaimed;
    bool exists;
}

contract Crowdfunding {
    mapping(uint256 => Campaign) public campaigns;
    mapping(address => mapping(uint256 => uint256)) public contributions;

    uint256 public campaignsCount;

    event CampaignCreated(
        uint256 campaignId,
        address creator,
        uint256 goal,
        uint256 deadline
    );
    event ContributionMade(
        uint256 campaignId,
        address contributor,
        uint256 amount
    );
    event FundsClaimed(uint256 campaignId, uint256 amount);
    event RefundIssued(uint256 campaignId, address contributor, uint256 amount);

    function createCampaign(uint256 goal, uint256 durationInDays) external {
        require(goal > 0, "Goal amount must be greater than zero");
        require(durationInDays > 0, "Days duration must be greater than zero");

        campaignsCount++;
        uint256 deadline = block.timestamp + (durationInDays * 1 days);

        campaigns[campaignsCount] = Campaign({
            creator: payable(msg.sender),
            goal: goal,
            deadline: deadline,
            totalFunds: 0,
            fundsClaimed: false,
            exists: true
        });

        emit CampaignCreated(campaignsCount, msg.sender, goal, deadline);
    }

    function contribute(uint256 campaignId) external payable {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.exists, "Campaign does not exist");
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution value must be greater than zero");

        campaign.totalFunds += msg.value;
        contributions[msg.sender][campaignId] += msg.value;

        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    function checkGoalReached(uint256 campaignId) external view returns (bool) {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.exists, "Campaign does not exist");

        return campaign.totalFunds >= campaign.goal;
    }

    function claimFunds(uint256 campaignId) external {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.exists, "Campaign does not exist");
        require(
            msg.sender == campaign.creator,
            "Only the creator can claim funds"
        );
        require(!campaign.fundsClaimed, "Funds already cleaimed");
        require(block.timestamp > campaign.deadline, "Campaign has not ended");
        require(campaign.totalFunds >= campaign.goal, "Campaign goal not met");

        campaign.fundsClaimed = true;
        uint256 amount = campaign.totalFunds;
        campaign.creator.transfer(amount);

        emit FundsClaimed(campaignId, amount);
    }

    function refund(uint256 campaignId) external {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.exists, "Campaign does not exist");
        require(block.timestamp > campaign.deadline, "Campaign has not ended");
        require(campaign.totalFunds < campaign.goal, "Funding goal was met");

        uint256 contributedAmount = contributions[msg.sender][campaignId];
        require(contributedAmount > 0, "No contribution to refund");

        campaign.totalFunds -= contributedAmount;
        contributions[msg.sender][campaignId] = 0;

        payable(msg.sender).transfer(contributedAmount);

        emit RefundIssued(campaignId, msg.sender, contributedAmount);
    }
}
