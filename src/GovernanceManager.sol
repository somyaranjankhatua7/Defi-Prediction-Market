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

    /** Event triggered when the stake amount is updated
     * - 'oldAmount' is the previous minimum stake amount before the update
     * - 'newAmount' is the updated minimum stake amount
     */
    event StakeAmountUpdated(uint256 oldAmount, uint256 newAmount);

    /**
     * Event triggered when the governance manager withdraws ETH from the contract
     * - 'governanceManager' is the address of the admin performing the withdrawal
     * - 'amount' is the total ETH withdrawn from the contract
     */
    event GovernanceManagerUnstake(
        address indexed governanceManager,
        uint256 amount
    );

    /**
     * Event triggered when the varified user withdraws ETH from the contract
     * - 'varifiedUser' is the address of the admin performing the withdrawal
     * - 'amount' is the total ETH withdrawn from the contract
     */
    event VarifiedUserUnstake(address indexed varifiedUser, uint256 amount);

    // Ensures the function can only be called by the GovernanceManager contract
    modifier onlyFromGovernanceManager() {
        require(governanceManager == msg.sender, "ONLY GOVERNANCE MANAGER!");
        _;
    }

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
    function exitGovernance(address _varifiedUser) public {
        require(
            _varifiedUser == msg.sender || msg.sender == governanceManager,
            "DON'T HAVE RIGHT!"
        );
        require(
            varifiedUser[_varifiedUser] >= 1 ether,
            "Not verified in governance."
        );
        uint256 stake = varifiedUser[_varifiedUser];
        delete varifiedUser[_varifiedUser];
        (bool status, ) = payable(_varifiedUser).call{value: stake}("");
        require(status, "Failed to send Ether");
        emit ExitedGovernance(_varifiedUser, stake, true);
    }

    // Function to update the stake amount for joining governance
    function updateStakeAmount(
        uint256 _amount
    ) public onlyFromGovernanceManager {
        uint256 oldAmount = stakeForGovernance;
        stakeForGovernance = _amount;
        emit StakeAmountUpdated(oldAmount, stakeForGovernance);
    }

    // Function transfer ether balance to governance owner
    function unstakeManagerBalance(
        uint256 _amount
    ) public onlyFromGovernanceManager {
        require(governanceManagerBalance >= _amount, "INSUFFICIENT BALANCE!");
        governanceManagerBalance -= _amount;
        (bool status, ) = payable(governanceManager).call{value: _amount}("");
        require(status, "FAILED TO SEND ETHER!");
        emit GovernanceManagerUnstake(governanceManager, _amount);
    }

    // Function to forcefully remove a user from governance
    function forceExitUserByManager(
        address _varifiedUser
    ) public onlyFromGovernanceManager {
        exitGovernance(_varifiedUser);
    }

    // Function transfer ether balance to varified user
    function unstakeUserBalance(uint256 _amount) public {
        require(
            (varifiedUser[msg.sender] - 1 ether) >= _amount,
            "INSUFFICIENT BALANCE!"
        );
        varifiedUser[msg.sender] = varifiedUser[msg.sender] - _amount;
        (bool status, ) = payable(msg.sender).call{value: _amount}("");
        require(status, "FAILED TO SEND ETHER!");
        emit VarifiedUserUnstake(msg.sender, _amount);
    }

    // Function to check if a user is verified
    function isVarifiedUser(address _varifiedUser) public view returns (bool) {
        if (varifiedUser[_varifiedUser] >= 1 ether) {
            return true;
        } else {
            return false;
        }
    }

    // Function to check varified user profit
    function checkVarifiedUserProfit(
        address _varifiedUser
    ) public view returns (uint256) {
        require(
            varifiedUser[_varifiedUser] >= 1 ether,
            "Not verified in governance."
        );
        return varifiedUser[_varifiedUser] - 1 ether;
    }

    // Function to check governance manager profit
    function checkManagerProfit() public view returns (uint256) {
        return governanceManagerBalance;
    }

    // Function to check governance total balance
    function totalBalanceOnGovernance() public view returns (uint256) {
        return address(this).balance;
    }
}
