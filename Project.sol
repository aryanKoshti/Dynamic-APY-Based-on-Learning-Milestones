// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the ERC20 token (assuming rewards are distributed as ERC20 tokens)
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DynamicAPY {
    // ERC20 token for reward distribution
    IERC20 public rewardToken;

    // Structure to hold user's learning data
    struct UserProgress {
        uint256 totalTimeSpent; // Total time spent learning (e.g., in hours)
        uint256 lastMilestoneTime; // Timestamp of the last milestone completion
        uint256 apyMultiplier; // APY multiplier based on milestones
        uint256 rewardsEarned; // Total rewards earned by the user
    }

    // Mapping from user address to their learning progress
    mapping(address => UserProgress) public userProgress;

    // Event for when rewards are distributed
    event RewardsDistributed(address user, uint256 rewardAmount);

    // Event for when a milestone is achieved
    event MilestoneAchieved(address user, uint256 milestoneTime, uint256 newAPYMultiplier);

    // Constructor to initialize the reward token
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to update user's progress (simulate completion of learning milestones)
    function updateUserProgress(address user, uint256 hoursSpent) external {
        UserProgress storage progress = userProgress[user];
        progress.totalTimeSpent += hoursSpent;

        // Check if the user has completed a new milestone (e.g., every 100 hours is a milestone)
        if (progress.totalTimeSpent >= 100) {
            // Increase APY multiplier for each 100 hours milestone reached
            uint256 milestonesReached = progress.totalTimeSpent / 100;
            progress.apyMultiplier = milestonesReached * 10; // For example, 10% APY per milestone

            // Reset time for the next milestone
            progress.totalTimeSpent = progress.totalTimeSpent % 100;

            emit MilestoneAchieved(user, block.timestamp, progress.apyMultiplier);
        }
    }

    // Function to calculate and distribute rewards based on APY multiplier
    function distributeRewards(address user) external {
        UserProgress storage progress = userProgress[user];

        // Calculate the amount of rewards to distribute
        uint256 apy = progress.apyMultiplier;
        uint256 rewardAmount = calculateReward(progress.totalTimeSpent, apy);

        // Transfer the rewards from the contract to the user
        require(rewardToken.transfer(user, rewardAmount), "Reward transfer failed");

        // Update total rewards earned by the user
        progress.rewardsEarned += rewardAmount;

        emit RewardsDistributed(user, rewardAmount);
    }

    // Internal function to calculate the rewards based on time spent and APY multiplier
    function calculateReward(uint256 timeSpent, uint256 apy) internal pure returns (uint256) {
        // For simplicity, we assume the reward is calculated based on time spent and APY
        return (timeSpent * apy) / 100;
    }

    // Function to get the current APY for a user
    function getUserAPY(address user) external view returns (uint256) {
        return userProgress[user].apyMultiplier;
    }

    // Function to get the total rewards earned by a user
    function getUserRewards(address user) external view returns (uint256) {
        return userProgress[user].rewardsEarned;
    }
}
