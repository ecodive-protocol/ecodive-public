// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {ECOD} from "../src/ECOD.sol";
import {PLASTIC} from "../src/PLASTIC.sol";

/// @title DeployTestnet — Deploy ECOD + PLASTIC to Base Sepolia
/// @notice For mainnet use a separate script with real multisig/timelock addresses.
contract DeployTestnet is Script {
    function run() external {
        uint256 deployerPk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPk);

        // Testnet — everything points to deployer for simplicity.
        // Mainnet MUST use separate multisigs / vesting contracts.
        address admin = deployer;
        address liquidity = deployer;
        address treasury = deployer;
        address presale = deployer;
        address team = deployer;
        address marketing = deployer;
        address dev = deployer;

        vm.startBroadcast(deployerPk);

        ECOD ecod = new ECOD(admin, liquidity, treasury, presale, team, marketing, dev);
        PLASTIC plastic = new PLASTIC(admin);

        vm.stopBroadcast();

        console.log("ECOD deployed at:", address(ecod));
        console.log("PLASTIC deployed at:", address(plastic));
        console.log("Deployer / admin:", deployer);
    }
}
