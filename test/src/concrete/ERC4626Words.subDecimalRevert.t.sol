// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {OPCODE_ERC4626_CONVERT_TO_ASSETS, OPCODE_ERC4626_CONVERT_TO_SHARES} from "src/abstract/ERC4626Extern.sol";
import {ExternDispatchV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterExternV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LossyConversionFromFloat} from "rain-math-float-0.1.1/src/error/ErrDecimalFloat.sol";
import {MockERC4626} from "test/utils/MockERC4626.sol";
import {MockERC20} from "test/utils/MockERC20.sol";

/// @notice Fuzz tests asserting that sub-decimal inputs revert with LossyConversionFromFloat.
/// A vault with 18-decimal shares and a 6-decimal asset; Float inputs with more decimal
/// places than the token precision cannot be converted losslessly and must revert.
contract ERC4626WordsRoundingTest is Test {
    ERC4626Words internal words;
    MockERC20 internal asset;
    MockERC4626 internal vault;

    /// @dev 1 share = 1.123456 USDC (non-unity rate, 18-decimal shares, 6-decimal asset).
    uint256 internal constant ASSETS_PER_SHARE = 1123456;

    function setUp() external {
        words = new ERC4626Words();
        asset = new MockERC20(6);
        vault = new MockERC4626(18, address(asset), ASSETS_PER_SHARE);
    }

    function makeDispatch(uint256 opcode) internal pure returns (ExternDispatchV2) {
        return ExternDispatchV2.wrap(bytes32(uint256(opcode) << 16));
    }

    function vaultItem() internal view returns (StackItem) {
        // forge-lint: disable-next-line(unsafe-typecast)
        return StackItem.wrap(bytes32(uint256(uint160(address(vault)))));
    }

    /// @notice An asset amount with 7 decimal places passed to convertToShares must
    /// revert with LossyConversionFromFloat because the vault only has 6-decimal precision.
    function testFuzzConvertToSharesSubDecimalReverts(int56 significand) external {
        vm.assume(significand > 0);
        // Significand must not be divisible by 10: otherwise significand*10^(-7+6) = significand/10
        // would be an integer and the conversion would succeed rather than revert.
        vm.assume(significand % 10 != 0);
        Float assetsFloat = LibDecimalFloat.packLossless(int256(significand), -7);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = vaultItem();
        inputs[1] = StackItem.wrap(Float.unwrap(assetsFloat));
        vm.expectRevert(abi.encodeWithSelector(LossyConversionFromFloat.selector, int256(significand), int256(-7)));
        words.extern(makeDispatch(OPCODE_ERC4626_CONVERT_TO_SHARES), inputs);
    }

    /// @notice A share amount with 19 decimal places passed to convertToAssets must
    /// revert with LossyConversionFromFloat because the vault only has 18-decimal precision.
    function testFuzzConvertToAssetsSubDecimalReverts(int56 significand) external {
        vm.assume(significand > 0);
        // Significand must not be divisible by 10: otherwise significand*10^(-19+18) = significand/10
        // would be an integer and the conversion would succeed rather than revert.
        vm.assume(significand % 10 != 0);
        Float sharesFloat = LibDecimalFloat.packLossless(int256(significand), -19);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = vaultItem();
        inputs[1] = StackItem.wrap(Float.unwrap(sharesFloat));
        vm.expectRevert(abi.encodeWithSelector(LossyConversionFromFloat.selector, int256(significand), int256(-19)));
        words.extern(makeDispatch(OPCODE_ERC4626_CONVERT_TO_ASSETS), inputs);
    }
}
