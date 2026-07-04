// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";
import {OperandV2} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";

/// @notice Derived contract that overrides the extern() seam to point at a
/// separately specified extern address, exposing both sub-parser word
/// functions so the emitted dispatch constants can be inspected.
contract OverriddenExternWords is ERC4626Words {
    address internal immutable sOverrideExtern;

    constructor(address overrideExtern) {
        sOverrideExtern = overrideExtern;
    }

    function extern() internal view override returns (address) {
        return sOverrideExtern;
    }

    function convertToAssetsSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToAssetsSubParser(constantsHeight, ioByte, operand);
    }

    function convertToSharesSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToSharesSubParser(constantsHeight, ioByte, operand);
    }
}

/// @notice Same harness on the unmodified contract for the default seam.
contract DefaultExternWords is ERC4626Words {
    function convertToAssetsSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToAssetsSubParser(constantsHeight, ioByte, operand);
    }
}

/// @notice Pins the extern() override seam: the dispatch constant a sub-parser
/// word emits embeds whatever address extern() returns (low 160 bits of the
/// EncodedExternDispatchV2), so a derived contract pointing at a separately
/// deployed extern routes eval-time dispatch there.
contract ERC4626SubParserExternOverrideTest is Test {
    address internal constant OVERRIDE_EXTERN = address(0x1234567890AbcdEF1234567890aBcdef12345678);

    function externAddressOf(bytes32[] memory constants) internal pure returns (address) {
        return address(uint160(uint256(constants[0])));
    }

    function testOverriddenExternEmbedsInConvertToAssetsDispatch() external {
        OverriddenExternWords words = new OverriddenExternWords(OVERRIDE_EXTERN);
        (bool ok, bytes memory bytecode, bytes32[] memory constants) =
            words.convertToAssetsSubParser(0, 0x10, OperandV2.wrap(0));
        assertTrue(ok, "sub-parser must handle the word");
        assertEq(bytecode.length, 4, "dispatch bytecode is 4 bytes");
        assertEq(constants.length, 1, "one dispatch constant");
        assertEq(externAddressOf(constants), OVERRIDE_EXTERN, "overridden extern must be embedded");
    }

    function testOverriddenExternEmbedsInConvertToSharesDispatch() external {
        OverriddenExternWords words = new OverriddenExternWords(OVERRIDE_EXTERN);
        (,, bytes32[] memory constants) = words.convertToSharesSubParser(0, 0x10, OperandV2.wrap(0));
        assertEq(externAddressOf(constants), OVERRIDE_EXTERN, "overridden extern must be embedded");
        assertTrue(uint256(constants[0]) >> 160 != 0, "shares opcode must encode above the address bits");
    }

    function testDefaultExternEmbedsSelf() external {
        DefaultExternWords words = new DefaultExternWords();
        (,, bytes32[] memory constants) = words.convertToAssetsSubParser(0, 0x10, OperandV2.wrap(0));
        assertEq(externAddressOf(constants), address(words), "default extern is address(this)");
    }
}
