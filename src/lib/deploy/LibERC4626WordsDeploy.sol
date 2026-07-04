// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {
    DEPLOYED_ADDRESS as ERC4626_WORDS_ADDR,
    BYTECODE_HASH as ERC4626_WORDS_HASH
} from "../../generated/ERC4626Words.pointers.sol";

/// @title LibERC4626WordsDeploy
/// @notice The deployed address and code hash of `ERC4626Words` when deployed
/// with the rain standard Zoltu deployer, plus a hand-maintained frozen
/// constant pair per published tag. The unsuffixed constants alias the
/// auto-regenerated pointers and track CURRENT SOURCE; the tag-suffixed
/// constants are pinned as literals (never derived from the pointers) so they
/// stay a faithful historical record — a redeploy of changed bytecode ADDS a
/// new tagged pair rather than editing an existing one. The
/// tagged-matches-current test goes red the moment source drifts past the
/// newest tag, making every deploy-generation bump an explicit, reviewed
/// change.
library LibERC4626WordsDeploy {
    /// @notice The deterministic Zoltu deploy address of the CURRENT source,
    /// identical on every rain supported network. Tracks the generated
    /// pointers.
    address constant ERC4626_WORDS_DEPLOYED_ADDRESS = ERC4626_WORDS_ADDR;

    /// @notice The runtime code hash of the CURRENT source. Tracks the
    /// generated pointers.
    bytes32 constant ERC4626_WORDS_DEPLOYED_CODEHASH = ERC4626_WORDS_HASH;

    /// @notice The deployed address of `ERC4626Words` as of the `0.1.0` tag.
    /// Pinned as a literal (not derived from the current pointers) so it
    /// remains a faithful record if source changes.
    address constant ERC4626_WORDS_DEPLOYED_ADDRESS_0_1_0 = 0xEcc14720E4BC47976411E4b6Dd1c0FFFf595EC6D;

    /// @notice The code hash of `ERC4626Words` as of the `0.1.0` tag.
    bytes32 constant ERC4626_WORDS_DEPLOYED_CODEHASH_0_1_0 =
        0x9905f7f79bbbbea0cde049efb56d1aed955479c30db2ee9b6eeae543e3b33bfb;
}
