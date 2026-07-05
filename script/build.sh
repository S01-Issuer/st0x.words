#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate all committed artifacts that rainix copy-artifacts diff-checks:
# authoring meta CBOR, generated pointer constants, and formatting.
# Everything runs in the repo default devshell, which provides both `rain`
# (not in rainix sol-shell) and `forge`.
# Requires soldeer deps installed: nix develop -c forge soldeer install
set -euo pipefail
nix develop -c erc4626-words-prelude
nix develop -c bash -euo pipefail -c '
  forge script --silent ./script/BuildPointers.sol
  forge fmt
'
