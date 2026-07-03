// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626, IERC4626Minimal} from "../../erc4626/LibERC4626.sol";
import {NotAnAddress} from "rainlang-0.1.2/src/error/ErrRainType.sol";

error UnexpectedInputs(uint256 expected, uint256 actual);

library LibOpERC4626ConvertToAssets {
    /// Extern integrity for erc4626-convert-to-assets.
    /// Always requires 2 inputs (vault address, shares) and produces 1 output (assets).
    function integrity(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Runs the erc4626-convert-to-assets operation.
    /// Reads the vault address (raw stack bits) and share amount from the
    /// stack, calls ERC-4626 convertToAssets, and pushes the resulting asset
    /// amount.
    /// @param operand Unused operand for this extern word.
    /// @param inputs [vault address as raw stack bits, shares as Float
    /// interpreted at the vault's share decimals].
    /// @return outputs a single-element stack: [assets as Float at the
    /// underlying asset token's decimals].
    function run(OperandV2 operand, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
        if (inputs.length < 2) revert UnexpectedInputs(2, inputs.length);
        bytes32 vault;
        Float sharesFloat;
        assembly ("memory-safe") {
            vault := mload(add(inputs, 0x20))
            sharesFloat := mload(add(inputs, 0x40))
        }

        // It is the rainlang author's responsibility to ensure the correctness
        // of vault as an address.
        // Casting to `uint160` is intentional to detect non-address values.
        //forge-lint: disable-next-line(unsafe-typecast)
        if (uint256(vault) != uint256(uint160(uint256(vault)))) revert NotAnAddress(uint256(vault));

        // Casting to `uint160` is safe because `NotAnAddress` above
        // ensures the value fits in 160 bits.
        //forge-lint: disable-next-line(unsafe-typecast)
        Float assetsFloat = LibERC4626.convertToAssets(IERC4626Minimal(address(uint160(uint256(vault)))), sharesFloat);

        StackItem[] memory outputs;
        assembly ("memory-safe") {
            outputs := mload(0x40)
            mstore(0x40, add(outputs, 0x40))
            mstore(outputs, 1)
            mstore(add(outputs, 0x20), assetsFloat)
        }
        return outputs;
    }
}
