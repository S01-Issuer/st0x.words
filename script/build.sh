#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate all committed artifacts that rainix copy-artifacts diff-checks:
# meta CBOR (needs `rain` from repo devshell) and function-pointer constants.
set -euo pipefail
nix develop -c erc4626-words-prelude
