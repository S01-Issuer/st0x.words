// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibERC4626WordsDeploy} from "../../../../src/lib/deploy/LibERC4626WordsDeploy.sol";

/// @notice Pins the newest tag-suffixed frozen constants to the current
/// (pointer-tracking) constants. Red here means source has drifted past the
/// newest recorded deploy generation — add a NEW tagged constant pair (and
/// deploy it) rather than editing an existing one.
contract LibERC4626WordsDeployTest is Test {
    function testNewestTagMatchesCurrentSource() external pure {
        assertEq(
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_ADDRESS_0_1_0,
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_ADDRESS,
            "source drifted past the 0.1.0 deploy generation: add a new tagged constant pair"
        );
        assertEq(
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_CODEHASH_0_1_0,
            LibERC4626WordsDeploy.ERC4626_WORDS_DEPLOYED_CODEHASH,
            "source drifted past the 0.1.0 deploy generation: add a new tagged constant pair"
        );
    }
}
