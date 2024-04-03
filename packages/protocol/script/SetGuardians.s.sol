// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../test/DeployCapability.sol";
import "../contracts/L1/gov/TaikoTimelockController.sol";
import "../contracts/L1/provers/Guardians.sol";

contract SetGuardians is DeployCapability {
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    address public timelockAddress = vm.envAddress("TIMELOCK_ADDRESS");
    address public guardianProver = vm.envAddress("GUARDIAN_PROVER");
    uint256 public minGuardians = vm.envUint("MIN_GUARDIANS");
    address[] public guardians = vm.envAddress("GUARDIANS", ",");

    function run() external {
        require(guardians.length != 0, "invalid guardians");

        vm.startBroadcast(privateKey);

        // setGuardiansByTimelock(timelockAddress);
        Guardians(guardianProver).setGuardians(guardians, uint8(minGuardians));

        vm.stopBroadcast();
    }

    function setGuardiansByTimelock(address timelock) internal {
        bytes32 salt = bytes32(block.timestamp);

        bytes memory payload =
            abi.encodeCall(Guardians.setGuardians, (guardians, uint8(minGuardians)));

        TaikoTimelockController timelockController = TaikoTimelockController(payable(timelock));

        timelockController.schedule(guardianProver, 0, payload, bytes32(0), salt, 0);

        timelockController.execute(guardianProver, 0, payload, bytes32(0), salt);

        for (uint256 i; i < guardians.length; ++i) {
            console2.log("New guardian prover added:");
            console2.log("index: ", i);
            console2.log("instance: ", guardians[0]);
        }
    }
}
