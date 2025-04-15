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

    /**
     * Event triggered when a user successfully joins the governance system
     * - 'user' is the address of the user joining governance
     * - 'stake' is the amount of ETH the user staked to join the governance
     * - 'verified' indicates whether the user has been verified as a governance
     * participant (true if verified, false otherwise)
     * */
    event JoinedGovernance(address indexed user, uint256 stake, bool verified);

    /**
     * Event triggered when a user exits the governance system
     * - 'user' is the address of the user exiting governance
     * - 'amountWithdraw' is the amount of ETH withdrawn when exiting governance
     * - 'exit' indicates if the user successfully exited governance
     * (true if they exited, false if exit failed)
     */
    event ExitedGovernance(
        address indexed user,
        uint256 amountWithdraw,
        bool exit
    );

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

    // Function for users to exit governance (withdraw their stake)
    function exitGovernance() public {
        require(
            varifiedUser[msg.sender] >= 1 ether,
            "Not verified in governance."
        );
        uint256 stake = varifiedUser[msg.sender];
        delete varifiedUser[msg.sender];
        (bool status, ) = payable(msg.sender).call{value: stake}("");
        require(status, "Failed to send Ether");
        emit ExitedGovernance(msg.sender, stake, true);
    }
}
