// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract GovernanceManager {
    /**
     * GovernanceManager contract to manage the governance system of the platform.
     * - `governanceManager`: The address of the contract owner/administrator responsible for managing governance.
     * - `governanceManagerBalance`: The address tracking the balance of the governance manager (contract owner).
     * - `varifiedUser`: A mapping to store the verification status and stake amount for verified users who have joined the governance.
     * - `stakeForGovernance`: The required stake amount (in Ether) for a user to become a verified participant in the governance system.
     */
    address public governanceManager;
    uint256 public governanceManagerBalance;
    mapping(address => uint256) public varifiedUser;
    uint256 public stakeForGovernance = 1 ether;

    event JoinedGovernance(address indexed user, uint256 stake, bool varified);

    constructor() {
        governanceManager = msg.sender;
    }

    // Function for users to join governance by staking ETH
    function joinGovernance() public payable {
        require(msg.value >= 1 ether, "Minimum stake required");
        require(varifiedUser[msg.sender] == 0, "Already joined in governance.");
        varifiedUser[msg.sender] = msg.value;
        emit JoinedGovernance(msg.sender, msg.value, true);
    }
}
