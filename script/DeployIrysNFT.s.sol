// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {IrysNFT} from "../src/IrysNFT.sol";

contract DeployIrysNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        uint256 maxMintsPerAddress = 3;

        IrysNFT irysNFT = new IrysNFT(
            maxMintsPerAddress,
            deployer,
            deployer
        );

        console.log("IrysNFT deployed at:", address(irysNFT));

        vm.stopBroadcast();
    }
}
