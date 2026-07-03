// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {LibDecimalFloat, Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";

/// @dev Minimal ERC-4626 interface covering only the conversion functions and
/// metadata needed by the Rain words.
interface IERC4626Minimal {
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
}

/// @dev Minimal ERC-20 metadata interface for reading the underlying asset's
/// decimal precision.
interface IERC20MetadataMinimal {
    function decimals() external view returns (uint8);
}

/// @title LibERC4626
/// @notice Core library for interacting with ERC-4626 tokenised vaults on-chain.
/// Takes the vault as a typed contract reference and handles conversion of the
/// AMOUNTS between the float representation used by the Rain interpreter and
/// the fixed-point uint256 values expected by ERC-4626 contracts.
library LibERC4626 {
    /// Reads the share and underlying-asset decimal scales from the vault:
    /// vault.decimals() then vault.asset() then assetToken.decimals(), giving
    /// both conversion functions a single, symmetric read path.
    /// @param vault The ERC-4626 vault contract.
    /// @return shareDecimals The decimal precision of the vault share token.
    /// @return assetDecimals The decimal precision of the underlying asset token.
    function _vaultScales(IERC4626Minimal vault) private view returns (uint8 shareDecimals, uint8 assetDecimals) {
        shareDecimals = vault.decimals();
        assetDecimals = IERC20MetadataMinimal(vault.asset()).decimals();
    }

    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    ///
    /// @dev ROUNDING: Per EIP-4626, convertToAssets MUST round DOWN (floor toward
    /// zero). Precision loss of up to 1 ulp per call favours the caller
    /// (order owner / share-holder): fewer assets are returned than the exact
    /// mathematical result, so any Rain order using this word to price its output
    /// pays out less than the ideal rate — the caller benefits, not the taker.
    /// An adversarial vault can engineer its exchange rate so that the truncated
    /// remainder is maximal on every call.
    ///
    /// @param vault The ERC-4626 vault contract.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return The equivalent amount of underlying assets, as a Rain Float,
    /// floor-rounded per the vault's convertToAssets implementation.
    function convertToAssets(IERC4626Minimal vault, Float sharesFloat) internal view returns (Float) {
        (uint8 shareDecimals, uint8 assetDecimals) = _vaultScales(vault);
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, shareDecimals);
        uint256 assetsRaw = vault.convertToAssets(sharesRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    ///
    /// @dev ROUNDING: Per EIP-4626, convertToShares MUST round DOWN (floor toward
    /// zero). Precision loss of up to 1 ulp per call favours the caller
    /// (order owner / share-holder): fewer shares are returned than the exact
    /// mathematical result, so any Rain order using this word to price its output
    /// pays out less than the ideal rate — the caller benefits, not the taker.
    /// An adversarial vault can engineer its exchange rate so that the truncated
    /// remainder is maximal on every call.
    ///
    /// @param vault The ERC-4626 vault contract.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return The equivalent number of vault shares, as a Rain Float,
    /// floor-rounded per the vault's convertToShares implementation.
    function convertToShares(IERC4626Minimal vault, Float assetsFloat) internal view returns (Float) {
        (uint8 shareDecimals, uint8 assetDecimals) = _vaultScales(vault);
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, assetDecimals);
        uint256 sharesRaw = vault.convertToShares(assetsRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
