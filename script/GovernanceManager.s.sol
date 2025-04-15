// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GovernanceManager} from "../src/GovernanceManager.sol";

contract CounterScript is Script {
    GovernanceManager public governanceManager;
    
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        governanceManager = new GovernanceManager();
        vm.stopBroadcast();
    }
}
