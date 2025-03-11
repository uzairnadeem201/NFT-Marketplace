// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OwnerNFT} from "../src/OwnerNFT.sol";
import {console} from "forge-std/console.sol";

contract DeployOwnerNFT is Script {
    function run() external {
        uint256 chainId = block.chainid;
        bytes32 deployerPrivateKey;

        if (chainId == 31337) {
            deployerPrivateKey = vm.envBytes32("PRIVATE_KEY");
            console.log("Deploying on Local Anvil...");
        } else if (chainId == 11155111) {
            deployerPrivateKey = vm.envBytes32("SEPOLIA_PRIVATE_KEY");
            console.log("Deploying on Sepolia...");
        } else {
            revert("Unsupported network!");
        }

        vm.startBroadcast(uint256(deployerPrivateKey));

        OwnerNFT nftContract = new OwnerNFT();
        console.log("OwnerNFT deployed at:", address(nftContract));

        vm.stopBroadcast();
    }
}
