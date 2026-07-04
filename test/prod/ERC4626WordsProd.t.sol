// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibERC4626WordsDeploy} from "../../src/lib/deploy/LibERC4626WordsDeploy.sol";

/// @notice Pins the production deployment: the pinned deterministic address on
/// every rain supported network must hold exactly the pinned bytecode. Red
/// here means the current source has not been deployed yet — the routine
/// pre-merge Zoltu deploy from this branch turns it green before merge.
contract ERC4626WordsProdTest is Test {
    function checkProdDeploy(string memory network) internal {
        vm.createSelectFork(network);
        assertEq(
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_ADDRESS.codehash,
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_CODEHASH,
            string.concat("ERC4626Words not deployed on ", network, " at the pinned address")
        );
    }

    function testProdDeployArbitrum() external {
        checkProdDeploy("arbitrum");
    }

    function testProdDeployBase() external {
        checkProdDeploy("base");
    }

    function testProdDeployBaseSepolia() external {
        checkProdDeploy("base_sepolia");
    }

    function testProdDeployFlare() external {
        checkProdDeploy("flare");
    }

    function testProdDeployPolygon() external {
        checkProdDeploy("polygon");
    }
}
