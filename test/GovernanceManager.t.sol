// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GovernanceManager} from "../src/GovernanceManager.sol";

contract GovernanceManagerTest is Test {
    GovernanceManager public governanceManager;

    function setUp() public {
        governanceManager = new GovernanceManager();
    }
}
